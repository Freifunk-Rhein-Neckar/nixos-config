{ config, lib, pkgs, ... }:
{

  systemd.network.netdevs."71-br-clffnix1" = {
    netdevConfig = {
      Name = "br-clffnix1";
      Kind = "bridge";
    };
  };
  systemd.network.netdevs."80-dummy-br-clffnix1" = {
    netdevConfig = {
      Name = "dum-br-clffnix1";
      Kind = "dummy";
    };
  };

  systemd.network.networks."80-dummy-br-clffnix1" = {
    matchConfig.Name = config.systemd.network.netdevs."80-dummy-br-clffnix1".netdevConfig.Name;
    networkConfig.Bridge = config.systemd.network.netdevs."71-br-clffnix1".netdevConfig.Name;
  };

  systemd.network.networks."71-br-clffnix1" = {
    matchConfig = {
      Name = config.systemd.network.netdevs."71-br-clffnix1".netdevConfig.Name;
    };
    networkConfig = {
      DHCP = "no";
      IPv6AcceptRA = false;
      LinkLocalAddressing = false;
    };
  };

  networking.firewall.extraForwardRules = lib.mkMerge [
    (lib.mkOrder 1051 ''
      iifname "${config.systemd.network.netdevs."71-br-clffnix1".netdevConfig.Name}" oifname "${config.systemd.network.netdevs."71-br-clffnix1".netdevConfig.Name}" counter accept
    '')
  ];

}
