{ config, lib, ... }:
{

  imports = [
    ../modules/boot/mbr.nix
  ];

  systemd.network.networks."10-mainif" = {
    matchConfig = {
      Name = "enp1s0";
    };
    networkConfig = {
      DHCP = "ipv4";
      IPv6AcceptRA = true;
      IPv6PrivacyExtensions = false;
    };
  };

}