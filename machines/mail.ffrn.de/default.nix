{ config, lib, pkgs, ... }:

{
  imports = [
    ../../roles/ffrn-hetzner-vm-incus.nix
  ];

  networking.hostName = "mail";
  networking.domain = "ffrn.de";

  deployment.targetHost = "2a01:4f8:140:4093:1266:6aff:feb2:86c8";


  system.stateVersion = "25.05"; # Did you read the comment?
}
