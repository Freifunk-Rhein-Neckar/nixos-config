{ config, lib, pkgs, ... }:

{
  imports = [
    ./gw.nix
  ];

  networking.hostName = "gw04";

  system.stateVersion = "25.05";
}
