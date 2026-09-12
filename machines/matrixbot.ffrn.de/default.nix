{ config, lib, pkgs, ... }:

{
  imports = [
    ../../roles/ffrn-hetzner-vm-incus.nix
    ./draupnir.nix
  ];

  networking.hostName = "matrixbot";
  networking.domain = "ffrn.de";

  services.nebula-ffrn.enable = false;

  system.stateVersion = "26.05";
}
