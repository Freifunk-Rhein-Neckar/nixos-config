{ config, lib, pkgs, ... }:
{
  virtualisation.incus = {
    enable = true;
    package = pkgs.incus;
    ui.enable = true;
    preseed = {
      config = {
        "core.https_address" = ":8443";
        "core.metrics_address" = ":8444";
        "core.metrics_authentication" = false;
      };
    };
  };

  services.nebula.networks."ffrn".firewall.inbound = lib.optionals (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) [
    {
      host = "any";
      port = 8443;
      proto = "tcp";
      groups = [ "noc" "incus" ];
    }
    {
      host = "any";
      port = 8444;
      proto = "tcp";
      groups = [ "noc" "prometheus" ];
    }
  ];

  networking.firewall.extraInputRules = ''
    ${ if (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) then ''
      iifname "${config.services.nebula.networks."ffrn".tun.device}" tcp dport 8443 counter accept comment "incus: accept from nebula"
      iifname "${config.services.nebula.networks."ffrn".tun.device}" tcp dport 8444 counter accept comment "incus: accept metrics from nebula"
    '' else ""}
  '';
}