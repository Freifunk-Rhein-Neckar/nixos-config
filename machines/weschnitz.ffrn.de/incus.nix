{ config, lib, pkgs, ... }:
{
  virtualisation.incus = {
    enable = true;
    package = pkgs.incus;
    ui.enable = true;
  };

  services.nebula.networks."ffrn".firewall.inbound = lib.optional (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) {
    host = "any";
    port = 8443;
    proto = "tcp";
    groups = [ "noc" "incus" ];
  };

  networking.firewall.extraInputRules = ''
    ${ if (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) then ''
      iifname "${config.services.nebula.networks."ffrn".tun.device}" tcp dport 8443 counter accept comment "incus: accept from nebula"
    '' else ""}
  '';
}