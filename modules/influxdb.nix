{ config, pkgs, lib, ... }:
{

  services.influxdb = {
    enable = true;
    package = pkgs.influxdb.overrideAttrs (old: rec {
      version = "1.12.2";
      src = pkgs.fetchFromGitHub {
        owner = "influxdata";
        repo = "influxdb";
        rev = "v${version}";
        hash = "sha256-Q05mKmAXxrk7IVNxUD8HHNKnWCxmNCdsr6NK7d7vOHM=";
      };
      vendorHash = "sha256-+6fOq/2YVz74Loy1pVLVRTr4OQm/fEBNtHy3+FQn51A=";
      ldflags = [
        "-s"
        "-w"
        "-X main.version=${version}"
      ];
    });
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
