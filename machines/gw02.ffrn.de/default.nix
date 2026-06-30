{ config, lib, pkgs, ... }:

{
  imports = [
    ./gw.nix
  ];

  networking.hostName = "gw02";

  system.stateVersion = "25.05";
}
