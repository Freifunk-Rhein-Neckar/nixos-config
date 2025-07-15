{ config, lib, pkgs, ... }:
{

  imports = [
    ../../modules/time.nix
    ../../modules/prometheus/exporter/node.nix
    ../../modules/borgbackup
    ./nebula.nix
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  networking.domain = lib.mkDefault "ffrn.de";

  users.users.root.openssh.authorizedKeys.keys = [
   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdnwVGpMaBv5Bx2XuIvuBI+b4HNaPYcuPoGSzZi/Z5R ffrn@tom v1"
   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC3J4QmBoP+jGrGEPhqqIHpB/puZQp81djIO10PhG7CH jevermeister"
   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDDGzzwqd+Bkn36jaWVfPTHVrEs3ZgHBPmwLWbtTfMA/ wusel+ffrn@uu.org"
   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1Yd4udgMwa1eEc9A+xha0QImtxnKFNB7XUncfgd6MG root@master.ffrn.de"
  ];

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
    iperf3
  ];

  # automatically remove unused old derivations
  nix.gc = {
    automatic = true;
    dates = "daily";
    randomizedDelaySec = "6h";
    options = "--delete-older-than 21d";
  };

  # Ensure that we can't even touch the configuration directory if we wanted to.
  fileSystems."/etc/nixos" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "size=1M,ro" ];
  };

}
