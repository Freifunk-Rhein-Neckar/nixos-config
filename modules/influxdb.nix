{ config, pkgs, lib, ... }:
{

  services.influxdb = {
    enable = true;
  };

  systemd.services.influxdb = {
    serviceConfig = {
      TimeoutStartSec = "10min";
    };
  };

  services.nebula.networks."ffrn".firewall.inbound = if (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) then [
    {
      host = "any";
      port = 8086;
      proto = "tcp";
      groups = [ "noc" "yanic" ];
    }
  ] else [];

  networking.firewall.extraInputRules = ''
    ${ if (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) then ''
      iifname "${config.services.nebula.networks."ffrn".tun.device}" tcp dport { 8086 } counter accept comment "influxdb: accept from nebula"
    '' else ""}
  '';

}
