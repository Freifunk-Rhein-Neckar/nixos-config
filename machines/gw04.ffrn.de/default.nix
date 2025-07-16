{ config, lib, pkgs, ... }:

{
  imports = [
    ./gw.nix
  ];

  networking.hostName = "gw04";

  deployment.targetHost = "2a01:4f8:140:4093:0:5eff:fe82:f3e9";

  system.stateVersion = "25.05";
}