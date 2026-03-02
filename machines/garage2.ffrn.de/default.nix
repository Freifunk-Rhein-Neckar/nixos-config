{ config, lib, pkgs, ... }:
{
  imports = [
    ../../roles/ffrn-hetzner-vm-incus.nix
    ../../modules/garage.nix
    ../../modules/garage-web.nix
  ];

  networking.hostName = "garage2";

  # services.garage.settings.rpc_public_addr = "192.168.100.42:3901";

  system.stateVersion = "25.11";
}
