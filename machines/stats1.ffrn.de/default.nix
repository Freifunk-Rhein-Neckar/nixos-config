# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./remote-build-users.nix
      ../../roles/netcup-vm-aarch64.nix
      ../../modules/prometheus/server.nix
      ../../modules/grafana.nix
      ../../modules/influxdb.nix
    ];

  networking.hostName = "stats1"; # Define your hostname.
  networking.domain = "ffrn.de";

  deployment.buildOnTarget = true;
  deployment.targetHost = "2a03:4000:60:11f::1";

  systemd.network.networks."10-mainif" = {
    matchConfig = {
      MACAddress = "26:79:b1:19:1a:9d";
    };
    address = [
      "2a03:4000:60:11f::1/64"
      #"2a03:4000:60:11f:2479:b1ff:fe19:1a9d/64"
    ];
  };

  modules.ffrn.borgbackup.enable = true;

  # Netcup falsely reports their storage as hdd, well at least that is the theory
  fileSystems."/".options = [ "ssd" ];

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
  system.stateVersion = "24.05"; # Did you read the comment?

}
