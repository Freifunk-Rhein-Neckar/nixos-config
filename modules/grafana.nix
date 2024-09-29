{ config, pkgs, lib, ... }:
{

  imports = [
    ./acme.nix
    ./nginx.nix
  ];

  services.grafana = {
    enable = true;
    settings = {
      "auth.anonymous".enabled = true;
      server.protocol = "socket";
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
      ];
    };
    declarativePlugins = with pkgs.grafanaPlugins; [
      # marcusolsson-dynamictext-panel
      grafana-piechart-panel
      # blackmirror1-singlestat-math-panel
      # marcusolsson-dynamictext-panel
      grafana-worldmap-panel
    ];
  };

  services.grafana-image-renderer = {
    enable = true;
    provisionGrafana = true;
  };

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
    forceSSL = true;
    useACMEHost = "${config.networking.hostName}.${config.networking.domain}";
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

}