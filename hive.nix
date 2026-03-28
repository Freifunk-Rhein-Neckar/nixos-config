let
  sources = import ./npins;
  inherit (sources) nixpkgs;
  inherit (sources) nixpkgs-unstable;
  lib = import (nixpkgs + "/lib");
in
{
  meta = {
    nixpkgs = import nixpkgs { };
    allowApplyAll = false;
  };

  defaults = { pkgs, config, ... }: {

    deployment.targetHost = lib.mkDefault "${config.networking.fqdn}";

    imports = [
      (sources.agenix + "/modules/age.nix")
      ./roles/all
    ];
  };

  "cloud1" = { name, nodes, ... }:  {
    imports = [ ./machines/cloud1.ffrn.de ];
  };

  "garage1" = { name, nodes, ... }:  {
    imports = [ ./machines/garage1.ffrn.de ];
  };

  "garage2" = { name, nodes, ... }:  {
    imports = [ ./machines/garage2.ffrn.de ];
  };

  "gw02" = { name, nodes, ... }:  {
    imports = [ ./machines/gw02.ffrn.de ];
    deployment.tags = [ "gw" "incus-vm" ];
  };

  "gw03" = { name, nodes, ... }:  {
    imports = [ ./machines/gw03.ffrn.de ];
    deployment.tags = [ "gw" "libvirt-vm" ];
  };

  "gw04" = { name, nodes, ... }:  {
    imports = [ ./machines/gw04.ffrn.de ];
    deployment.tags = [ "gw" "incus-vm" ];
  };

  "gw05" = { name, nodes, ... }:  {
    imports = [ ./machines/gw05.ffrn.de ];
    deployment.tags = [ "gw" "libvirt-vm" ];
  };

  #"gw06" = { name, nodes, ... }:  {
  #  imports = [ ./machines/gw06.ffrn.de ];
  #  deployment.tags = [ "gw" "libvirt-vm" ];
  #};

  "gw07" = { name, nodes, ... }:  {
    imports = [ ./machines/gw07.ffrn.de ];
    deployment.tags = [ "gw" "incus-vm" ];
  };

  "gw08" = { name, nodes, ... }:  {
    imports = [ ./machines/gw08.ffrn.de ];
    deployment.tags = [ "gw" "libvirt-vm" ];
  };

  "gw09" = { name, nodes, ... }:  {
    imports = [ ./machines/gw09.ffrn.de ];
    deployment.tags = [ "gw" "libvirt-vm" ];
  };

  "itter" = { name, nodes, ... }:  {
    imports = [ ./machines/itter.ffrn.de ];
    deployment.tags = [ "vmhost" ];
  };

  "mail01" = { name, nodes, ... }:  {
    imports = [ ./machines/mail01.ffrn.de ];
    deployment.tags = [ "mail" "hetzner-vm" ];
  };

  "weschnitz" = { name, nodes, ... }:  {
    imports = [ ./machines/weschnitz.ffrn.de ];
    deployment.tags = [ "vmhost" ];
  };

  #"map2" = { name, nodes, ... }:  {
  #  imports = [ ./machines/map2.ffrn.de ];
  #};

  "sso1" = { name, nodes, ... }:  {
    imports = [ ./machines/sso1.ffrn.de ];
  };

  "stats1" = { name, nodes, ... }:  {
    imports = [ ./machines/stats1.ffrn.de ];
  };

  "web1" = { name, nodes, ... }:  {
    imports = [ ./machines/web1.ffrn.de ];
  };
}
