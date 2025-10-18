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

  deployment.targetHost = "2a01:4f8:160:624c:5054:ff:fe3f:c2ea";

  system.stateVersion = "25.05"; # Did you read the comment?

}
