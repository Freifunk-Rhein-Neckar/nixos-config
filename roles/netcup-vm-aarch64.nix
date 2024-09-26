{ config, lib, ... }:
{

  imports = [
    ../modules/boot/uefi.nix
  ];

  systemd.network.networks."10-mainif" = {
    networkConfig = {
      DHCP = "ipv4";
      Gateway = "fe80::1";
      IPv6AcceptRA = false;
      DNS = [ "2a03:4000:8000::fce6" "2a03:4000:0:1::e1e6" "46.38.252.230" "46.38.225.230" ];
    };
  };

}