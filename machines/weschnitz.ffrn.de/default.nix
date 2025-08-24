{ config, lib, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./network.nix
      ./incus.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.swraid.enable = true;


  networking.hostName = "weschnitz"; # Define your hostname.
  networking.hostId = "312916c4";

  modules.ffrn.borgbackup.enable = false;

  systemd.network.links."10-mainif" = {
    matchConfig = {
      MACAddress = "7c:10:c9:21:ee:93";
      Type = "ether";
    };
    linkConfig = {
      Name = "mainif";
    };
  };

  systemd.network.networks."10-mainif" = {
    matchConfig = {
      MACAddress = config.systemd.network.links."10-mainif".matchConfig.MACAddress;
      Type = "ether";
    };
    networkConfig = {
      IPv6AcceptRA = false;
      DNS = [ "2a01:4ff:ff00::add:2" "2a01:4ff:ff00::add:1" "185.12.64.1" "185.12.64.2" ];
      IPv6Forwarding = true;
      # VLAN = [ config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name ];
    };
    address = [ "176.9.161.125/29" "2a01:4f8:160:624c::2/128" ];
    routes = [
      { Gateway = "fe80::1"; }
      { Gateway = "176.9.161.121"; GatewayOnLink = true; }
      { Destination = "172.16.0.0/12"; Type = "unreachable"; Metric = 999999; }
      { Destination = "192.168.0.0/16"; Type = "unreachable"; Metric = 999999; }
      { Destination = "10.0.0.0/8"; Type = "unreachable"; Metric = 999999; }
      { Destination = "fc00::/7"; Type = "unreachable"; Metric = 999999; }
    ];
  };

  virtualisation.libvirtd.enable = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

