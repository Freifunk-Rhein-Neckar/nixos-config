{ name, config, lib, pkgs, ... }:
{

  imports = [
    ../../roles/gw/ffrn-hetzner-vm-itter.nix
  ];

  modules.ffrn-gateway = {
    publicIPv4 = "94.130.243.232";
    publicIPv6 = "2a01:4f8:140:4093::ff2:2";
  };

  modules.freifunk.gateway.domains = {
    dom0 = {
      ipv4.dhcpV4.pools = [
        "10.142.112.1 - 10.142.115.254"
      ];
    };
  };
}