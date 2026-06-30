{ config, lib, pkgs, ... }:

{
  imports = [
    ./gw.nix
  ];

  networking.hostName = "gw07";

  system.stateVersion = "25.05";
}
