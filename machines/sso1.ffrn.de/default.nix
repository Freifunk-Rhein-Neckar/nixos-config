# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ../../roles/ffrn-hetzner-vm-incus.nix
    ../../modules/kanidm.nix
  ];

  networking.hostName = "sso1";
  networking.domain = "ffrn.de";

  system.stateVersion = "25.11";
}
