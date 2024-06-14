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
