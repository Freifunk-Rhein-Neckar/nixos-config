{ name, nodes, config, pkgs, lib, ... }:
{
  imports = [
    ./ffrn-hetzner-vm.nix
    ../ffrn-hetzner-vm-incus.nix
  ];

  modules.freifunk.gateway.domains = {
    # TODO: this is the itter prefix, use for now until nodes know the the new prefix
    dom0.ipv6.prefixes."2a01:4f8:140:7700::/64".announce = true;
    # TODO: enable once nodes know the the prefix
    dom0.ipv6.prefixes."2a01:4f8:222:f300::/64".announce = false;
  };

}
