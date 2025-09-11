{ config, lib, pkgs, ... }:
{
  imports = [
    (import (import ../npins).nixos-mailserver)
  ];
}
