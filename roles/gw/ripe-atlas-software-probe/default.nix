{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ./ripe-atlas-software-probe.nix
  ];

}