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
    deployment.tags = [ "incus-vm" "hetzner-ffrn" ];
  };

  "garage1" = { name, nodes, ... }:  {
    imports = [ ./machines/garage1.ffrn.de ];
    deployment.tags = [ "incus-vm" "hetzner-ffrn" ];
  };

  "garage2" = { name, nodes, ... }:  {
    imports = [ ./machines/garage2.ffrn.de ];
    deployment.tags = [ "incus-vm" "hetzner-ffrn" ];
  };

  "gw02" = { name, nodes, ... }:  {
    imports = [ ./machines/gw02.ffrn.de ];
    deployment.tags = [ "gw" "incus-vm" "hetzner-ffrn" ];
  };

  #"gw03" = { name, nodes, ... }:  {
  #  imports = [ ./machines/gw03.ffrn.de ];
  #  deployment.tags = [ "gw" "libvirt-vm" ];
  #};

  "gw04" = { name, nodes, ... }:  {
    imports = [ ./machines/gw04.ffrn.de ];
    deployment.tags = [ "gw" "incus-vm" "hetzner-ffrn" ];
  };

  "gw05" = { name, nodes, ... }:  {
    imports = [ ./machines/gw05.ffrn.de ];
    deployment.tags = [ "gw" "incus-vm" "hetzner-ffrn" ];
  };

  #"gw06" = { name, nodes, ... }:  {
  #  imports = [ ./machines/gw06.ffrn.de ];
  #  deployment.tags = [ "gw" "libvirt-vm" ];
  #};

  "gw07" = { name, nodes, ... }:  {
    imports = [ ./machines/gw07.ffrn.de ];
    deployment.tags = [ "gw" "incus-vm" "hetzner-ffrn" ];
  };

  "gw08" = { name, nodes, ... }:  {
    imports = [ ./machines/gw08.ffrn.de ];
    deployment.tags = [ "gw" "incus-vm" "hetzner-ffrn" ];
  };

  #"gw09" = { name, nodes, ... }:  {
  #  imports = [ ./machines/gw09.ffrn.de ];
  #  deployment.tags = [ "gw" "libvirt-vm" ];
  #};

  "itter" = { name, nodes, ... }:  {
    imports = [ ./machines/itter.ffrn.de ];
    deployment.tags = [ "vmhost" ];
  };

  "mail01" = { name, nodes, ... }:  {
    imports = [ ./machines/mail01.ffrn.de ];
    deployment.tags = [ "mail" "hetzner-cloud" ];
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
    deployment.tags = [ "incus-vm" "hetzner-ffrn" ];
  };

  "stats1" = { name, nodes, ... }:  {
    imports = [ ./machines/stats1.ffrn.de ];
    deployment.tags = [ "netcup" ];
  };

  "web1" = { name, nodes, ... }:  {
    imports = [ ./machines/web1.ffrn.de ];
    deployment.tags = [ "incus-vm" "hetzner-ffrn" ];
  };
}
