{ name, config, lib, pkgs, ... }:
{

  imports = [
    ../../roles/gw/hetzner-vm-elsenz.nix
  ];

  modules.ffrn-gateway = {
    publicIPv4 = "138.201.30.247";
    publicIPv6 = "2a01:4f8:171:3242::ff1:3";
  };

  modules.freifunk.gateway.domains = {
    dom0 = {
      ipv4.dhcpV4.pools = [
        "10.142.104.1 - 10.142.107.254"
      ];
    };
  };
}