{ config, lib, pkgs, ... }:
{

  imports = [
    ../../modules/time.nix
    ./prometheus-node-exporter.nix
  ];

  boot.kernelParams = [ "console=ttyS0,115200n8" ];
  boot.loader.grub = {
    enable = true;
    configurationLimit = 5;
    efiSupport = false;
    extraConfig = "
      serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
      terminal_input serial
      terminal_output serial
    ";
    device = lib.mkDefault "/dev/sda";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdnwVGpMaBv5Bx2XuIvuBI+b4HNaPYcuPoGSzZi/Z5R ffrn@tom v1"
   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC3J4QmBoP+jGrGEPhqqIHpB/puZQp81djIO10PhG7CH jevermeister"
   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDDGzzwqd+Bkn36jaWVfPTHVrEs3ZgHBPmwLWbtTfMA/ wusel+ffrn@uu.org"
   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1Yd4udgMwa1eEc9A+xha0QImtxnKFNB7XUncfgd6MG root@master.ffrn.de"
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

  networking.useNetworkd = true;
  networking.nftables.enable = true;
  networking.usePredictableInterfaceNames = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "de";
    useXkbConfig = true; # use xkb.options in tty.
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    htop
    mtr
    ethtool
    tmux
    tcpdump
    dig
    ncdu
  ];

}
