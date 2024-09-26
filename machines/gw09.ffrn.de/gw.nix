{ name, config, lib, pkgs, ... }:
{

  imports = [
    ../../roles/gw/ffrn-hetzner-vm-elsenz.nix
  ];

  modules.freifunk.gateway.meta = {
    latitude = "50.478158406";
    longitude = "12.335886955";
  };

  modules.ffrn-gateway = {
    publicIPv4 = "138.201.30.244";
    publicIPv6 = "2a01:4f8:171:3242::ff1:9";
  };

  modules.freifunk.gateway.domains = {
    dom0 = {
      ipv4.dhcpV4.pools = [
        "10.142.128.1 - 10.142.131.254"
      ];
    };
  };
}