{ name, config, lib, pkgs, ... }:
{

  imports = [
    ../../roles/gw/hetzner-vm-weschnitz.nix
  ];

  modules.ffrn-gateway = {
    publicIPv4 = "88.198.112.222";
    publicIPv6 = "2a01:4f8:160:624c::ff3:8";
  };

  modules.freifunk.gateway.domains = {
    dom0 = {
      ipv4.dhcpV4.pools = [
        "10.142.108.1 - 10.142.111.254"
      ];
    };
  };
}