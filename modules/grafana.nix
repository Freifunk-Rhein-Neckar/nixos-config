{ config, pkgs, lib, ... }:
{

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


}