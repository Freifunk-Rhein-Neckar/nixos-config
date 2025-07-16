{ config, lib, ... }:
{

  imports = [
    ../modules/boot/incus.nix
  ];

  systemd.network.networks."10-mainif" = {
    matchConfig = {
      Name = "enp5s0";
    };
    networkConfig = {
      DHCP = "ipv4";
      IPv6AcceptRA = true;
      IPv6PrivacyExtensions = false;
    };
  };

}