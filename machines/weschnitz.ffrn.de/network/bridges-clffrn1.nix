{ config, lib, pkgs, ... }:
{

  systemd.network.netdevs."71-br-clffrn1" = {
    netdevConfig = {
      Name = "br-clffrn1";
      Kind = "bridge";
    };
  };
  systemd.network.netdevs."80-dummy-br-clffrn1" = {
    netdevConfig = {
      Name = "dum-br-clffrn1";
      Kind = "dummy";
    };
  };

  systemd.network.networks."80-dummy-br-clffrn1" = {
    matchConfig.Name = config.systemd.network.netdevs."80-dummy-br-clffrn1".netdevConfig.Name;
    networkConfig.Bridge = config.systemd.network.netdevs."71-br-clffrn1".netdevConfig.Name;
  };

  systemd.network.networks."71-br-clffrn1" = {
    matchConfig = {
      Name = config.systemd.network.netdevs."71-br-clffrn1".netdevConfig.Name;
    };
    networkConfig = {
      DHCP = "no";
      IPv6AcceptRA = false;
      LinkLocalAddressing = false;
    };
  };

  networking.firewall.extraForwardRules = lib.mkMerge [
    (lib.mkOrder 1050 ''
      iifname "${config.systemd.network.netdevs."71-br-clffrn1".netdevConfig.Name}" oifname "${config.systemd.network.netdevs."71-br-clffrn1".netdevConfig.Name}" counter accept
    '')
  ];

}
