{ config, pkgs, lib, ... }:
{

  imports = [
    ./acme.nix
    ./nginx.nix
  ];

  services.grafana = {
    enable = true;
    settings = {
      "auth.anonymous" = {
        enabled = true;
        org_name = "FFRN";
      };
      server = {
        protocol = "socket";
        root_url = "https://stats.ffrn.de";
      };
      rendering.callback_url = "https://stats1.ffrn.de";
      rendering.server_url = "http://localhost:${builtins.toString config.services.grafana-image-renderer.settings.service.port}/render";

      smtp = {
        enabled = true;
        host = "$__file{${config.age.secrets."smtp-host".path}}";
        user = "$__file{${config.age.secrets."smtp-user".path}}";
        password = "$__file{${config.age.secrets."smtp-password".path}}";
        skip_verify = false;
        from_address = "$__file{${config.age.secrets."smtp-from_address".path}}";
        from_name = "FFRN Grafana";

        # "smtp-user" "smtp-host" "smtp-password" "smtp-from_address"
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "prometheus.${builtins.toString config.networking.domain}";
          url = "http://prometheus.int.ffrn.de:9090";
          isDefault = true;
          type = "prometheus";
          editable = false;
        }
        {
          name = "influxdb.${builtins.toString config.networking.domain}";
          url = "http://influxdb.int.ffrn.de:8086";
          type = "influxdb";
          editable = false;
          jsonData.dbName = "ffrn";
        }
      ];
    };
    declarativePlugins = with pkgs.grafanaPlugins; [
      # marcusolsson-dynamictext-panel
      grafana-piechart-panel
      # blackmirror1-singlestat-math-panel
      marcusolsson-dynamictext-panel
      grafana-worldmap-panel
    ];
  };

  services.grafana-image-renderer = {
    enable = true;
    settings = {
      service.metrics = {
        enabled = true;
        collectDefaultMetrics = true;
        requestDurationBuckets = [1 5 7 9 11 13 15 20 30];
      };
      rendering = {
        timingMetrics = true;
      };
    };
  };

  services.nebula.networks."ffrn".firewall.inbound = if (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) then [
    {
      host = "any";
      port = config.services.grafana-image-renderer.settings.service.port;
      proto = "tcp";
      groups = [ "noc" "prometheus" "grafana" ];
    }
  ] else [];

  networking.firewall.extraInputRules = ''
    ${ if (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) then ''
      iifname "${config.services.nebula.networks."ffrn".tun.device}" tcp dport ${builtins.toString config.services.grafana-image-renderer.settings.service.port} counter accept comment "grafana-image-renderer: accept from nebula"
    '' else ""}
  '';

  systemd.services.nginx.serviceConfig.SupplementaryGroups = [ "grafana" ];

  services.nginx.virtualHosts."stats.ffrn.de" = {
    serverAliases = [
      "stats.int.ffrn.de"
      "stats1.ffrn.de"
      "stats1.int.ffrn.de"
    ];
    default = true;
    locations."/" = {
      proxyPass = "http://unix:${config.services.grafana.settings.server.socket}";
    };
    locations."/render/" = {
      proxyPass = "http://unix:${config.services.grafana.settings.server.socket}";
      extraConfig = ''
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        add_header X-FFRN-LOCAL-Cache-Status $upstream_cache_status;
        proxy_cache rendercache;
        proxy_cache_valid 300s;
        proxy_cache_lock on;
        proxy_cache_lock_age 60s;
        proxy_cache_lock_timeout 60s;
        proxy_ignore_headers Cache-Control Expires;
        proxy_cache_use_stale error timeout invalid_header updating http_500 http_502 http_503 http_504;
      '';
    };
    forceSSL = true;
    useACMEHost = "${config.networking.hostName}.${config.networking.domain}";
  };

  services.nginx.proxyCachePath."rendercache" = {
    enable = true;
    maxSize = "1024M";
    levels = "1:2";
    keysZoneSize = "10m";
    keysZoneName = "rendercache";
    inactive = "10m";
  };

  services.nginx.virtualHosts."s.ffrn.de" = {
    redirectCode = 308;
    globalRedirect = "stats.ffrn.de";
    forceSSL = true;
    useACMEHost = "${config.networking.hostName}.${config.networking.domain}";
  };

  security.acme = {
    certs."${config.networking.hostName}.${config.networking.domain}" = {
      extraDomainNames = [
        "stats1.int.ffrn.de"
        "stats1.ffrn.de"
        "stats.int.ffrn.de"
        "stats.ffrn.de"
        "s.ffrn.de"
      ];
    };
  };

  age.secrets = lib.listToAttrs (map (name: {
    name = name;
    value = {
      file = ../secrets/stats1/${name}.age;
      mode = "0400";
      owner = "grafana";
      group = "grafana";
    };
  }) [ "smtp-user" "smtp-host" "smtp-password" "smtp-from_address" ] );

}