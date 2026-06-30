# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./gw.nix
    ];

  networking.hostName = "gw08";
  networking.domain = "ffrn.de";

  system.stateVersion = "25.05"; # Did you read the comment?

}
