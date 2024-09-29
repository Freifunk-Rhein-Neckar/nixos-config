{ lib, pkgs, config, name, ... }:
{

  services.prometheus.alertmanager = {
    enable = true;
    extraFlags = [
      "--cluster.listen-address=" # empty string disables HA mode
    ];

    webExternalUrl = "http://alertmanager.int.ffrn.de/";

    environmentFile = config.age.secrets."alertmanager-secrets".path;

    configText = ''
      global:

      route:
        # The labels by which incoming alerts are grouped together
        group_by: ['alertname', 'alertstate', 'cluster', 'service']

        # When a new group of alerts is created by an incoming alert, wait at
        # least 'group_wait' to send the initial notification.
        group_wait: 1m

        # When the first notification was sent, wait 'group_interval' to send a batch
        # of new alerts that started firing for that group.
        group_interval: 15m

        # If an alert has successfully been sent, wait 'repeat_interval' to
        # resend them.
        repeat_interval: 12h

        receiver: pushover

        routes:
          - match:
              job: icmp4_extra
            receiver: pushover-tom
            continue: false
          - match:
              job: icmp6_extra
            receiver: pushover-tom
            continue: false
          - match:
              severity: page
            receiver: pushover
            continue: true
          # - receiver: ffrn-mon-matrix

      inhibit_rules:
        - source_match:
            alertname: MachineDown
          target_match_re:
            alertname: (ExporterDown|Icmp4Timeout|Icmp6Timeout|DNS.+)
          equal: [instance]

      receivers:
        - name: pushover
          pushover_configs:
            - user_key: "$PUSHOVER_USER_KEY"
              token: "$PUSHOVER_APP_TOKEN"
              priority: '{{ if eq .Status "firing" }}0{{ else }}-1{{ end }}'
        - name: pushover-tom
          pushover_configs:
            - user_key: "$PUSHOVER_USER_KEY_TOM"
              token: "$PUSHOVER_APP_TOKEN_TOM"
              priority: '{{ if eq .Status "firing" }}0{{ else }}-1{{ end }}'
    '';

  };

  services.nebula.networks."ffrn".firewall.inbound = if (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) then [
    {
      host = "any";
      port = config.services.prometheus.alertmanager.port;
      proto = "tcp";
      groups = [ "noc" "prometheus" ];
    }
  ] else [];

  age.secrets."alertmanager-secrets" = {
    file = ../../secrets/${name}/alertmanager-secrets.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };
}