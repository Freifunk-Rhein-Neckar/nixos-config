{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nebula/lighthouse.nix
    ./mailserver.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.supportedFilesystems = [ "zfs" ];

  networking.hostName = "mail01";

  networking.hostId = "ddf4939d";

  systemd.network.networks."10-mainif" = {
    matchConfig = {
      MACAddress = "96:00:00:50:d2:d7";
    };
    address = [
      "2a01:4f8:c17:6b7f::1/64"
    ];
    networkConfig = {
      DHCP = "ipv4";
      Gateway = "fe80::1";
      IPv6AcceptRA = false;
      DNS = [ "2a01:4ff:ff00::add:2" "2a01:4ff:ff00::add:1" "185.12.64.2" "185.12.64.1" ];
    };
  };

  system.stateVersion = "25.11";

}