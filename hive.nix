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

  "gw02" = { name, nodes, ... }:  {
    imports = [ ./machines/gw02.ffrn.de ];
  };

  "gw03" = { name, nodes, ... }:  {
    imports = [ ./machines/gw03.ffrn.de ];
  };

  "gw04" = { name, nodes, ... }:  {
    imports = [ ./machines/gw04.ffrn.de ];
  };

  "gw05" = { name, nodes, ... }:  {
    imports = [ ./machines/gw05.ffrn.de ];
  };

  "gw06" = { name, nodes, ... }:  {
    imports = [ ./machines/gw06.ffrn.de ];
  };

  "gw07" = { name, nodes, ... }:  {
    imports = [ ./machines/gw07.ffrn.de ];
  };

  "gw08" = { name, nodes, ... }:  {
    imports = [ ./machines/gw08.ffrn.de ];
  };

  "gw09" = { name, nodes, ... }:  {
    imports = [ ./machines/gw09.ffrn.de ];
  };
}
