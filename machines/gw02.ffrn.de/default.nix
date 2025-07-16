{ config, lib, pkgs, ... }:

{
  imports = [
    ./gw.nix
  ];

  networking.hostName = "gw02";

  deployment.targetHost = "2a01:4f8:140:4093:0:5eff:fe82:f3e8";

  system.stateVersion = "25.05";
}