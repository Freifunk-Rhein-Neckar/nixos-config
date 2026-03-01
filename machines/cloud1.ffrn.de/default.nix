# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ../../roles/ffrn-hetzner-vm-incus.nix
    # ../../modules/nextcloud.nix
  ];

  networking.hostName = "cloud1";
  networking.domain = "ffrn.de";

  deployment.targetHost = "2a01:4f8:160:624c:1266:6aff:fef1:2a32";

  system.stateVersion = "25.11";
}
