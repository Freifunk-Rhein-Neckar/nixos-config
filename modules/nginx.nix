{ config, pkgs, lib, ... }:
{

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  networking.firewall.extraInputRules = ''
    ${ if (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) then ''
      iifname "${config.services.nebula.networks."ffrn".tun.device}" tcp dport 80 counter accept comment "nginx: accept http from nebula"
      iifname "${config.services.nebula.networks."ffrn".tun.device}" tcp dport 443 counter accept comment "nginx: accept https from nebula"
    '' else ""}
  '';

}