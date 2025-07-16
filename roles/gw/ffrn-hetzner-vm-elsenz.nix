{ name, nodes, config, pkgs, lib, ... }:
{
  imports = [
    ./ffrn-hetzner-vm.nix
    ../ffrn-hetzner-vm.nix
  ];

  modules.freifunk.gateway.domains = {
    dom0.ipv6.prefixes."2a01:4f8:171:fcff::/64".announce = true;
  };

}