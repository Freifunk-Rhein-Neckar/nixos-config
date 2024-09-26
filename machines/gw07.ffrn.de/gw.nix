{ name, config, lib, pkgs, ... }:
{

  imports = [
    ../../roles/gw/ffrn-hetzner-vm-itter.nix
  ];

  modules.ffrn-gateway = {
    publicIPv4 = "94.130.243.235";
    publicIPv6 = "2a01:4f8:140:4093::ff2:7";
  };

  modules.freifunk.gateway.domains = {
    dom0 = {
      ipv4.dhcpV4.pools = [
        "10.142.132.1 - 10.142.135.254"
      ];
    };
  };
}