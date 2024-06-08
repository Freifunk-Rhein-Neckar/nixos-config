let
  sources = import ./nix/sources.nix;
  inherit (sources) nixpkgs;
  inherit (sources) nixpkgs-unstable;
  lib = import (nixpkgs + "/lib");
in
{
  meta = {
    nixpkgs = import nixpkgs { };
  };

  defaults = { pkgs, config, ... }: {

    deployment.targetHost = lib.mkDefault "${config.networking.fqdn}";

    # This module will be imported by all hosts
    environment.systemPackages = with pkgs; [
      vim
      wget
      curl
      htop
      mtr
      ethtool
      tmux
      tcpdump
      dig
      ncdu
    ];

    imports = [
      (sources.agenix + "/modules/age.nix")
      ./roles/all
    ];
  };

  "gw09" = { name, nodes, ... }:  {
    imports = [ 
      ./machines/gw09.ffrn.de
      ./roles/gw
    ];
  };
}
