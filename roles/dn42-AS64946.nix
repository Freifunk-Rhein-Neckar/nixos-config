{ lib, config, pkgs, ... }:
{
  imports = [
    ../modules/dn42
  ];

  services.freifunk.bird = {
    extraVariables = ''
      define DN42_AS = 64946;
    '';
    extraConfig = ''
      protocol static dn42_static6 {
        route fdc3:67ce:cc7e::/48 reject;

        ipv6 {
          import all;
          export none;
        };
      }
    '';
  };

  networking.firewall.extraForwardRules = ''
    ip saddr { 172.16.0.0/12, 10.0.0.0/8 } ip daddr { 172.16.0.0/12, 10.0.0.0/8 } iifname { "4242*", "${config.systemd.network.networks."10-mainif".matchConfig.Name}", "bat-dom*" } oifname { "4242*", "${config.systemd.network.networks."10-mainif".matchConfig.Name}", "bat-dom*" } counter accept comment "forward DN42 traffic v4";
    ip6 saddr { fd00::/8 } ip6 daddr { fd00::/8 } iifname { "4242*", "${config.systemd.network.networks."10-mainif".matchConfig.Name}", "bat-dom*" } oifname { "4242*", "${config.systemd.network.networks."10-mainif".matchConfig.Name}", "bat-dom*" } counter accept comment "forward DN42 traffic v6";
    counter
  '';

  # networking.firewall.extraInputRules = ''
  #   ip saddr { 10.223.254.48, 10.223.254.49 } iifname "${config.systemd.network.networks."10-mainif".matchConfig.Name}" tcp dport bgp counter accept comment "accept BGP ${config.systemd.network.networks."10-mainif".matchConfig.Name}"
  #   ip6 saddr { fd01:67c:2ed8:a::48:1, fd01:67c:2ed8:a::49:1 } iifname "${config.systemd.network.networks."10-mainif".matchConfig.Name}" tcp dport bgp counter accept comment "accept BGP ${config.systemd.network.networks."10-mainif".matchConfig.Name}"
  #   ip6 saddr { fd64:6fff:ffda:a::50:1, fd64:6fff:ffda:a::51:1 } iifname "${config.systemd.network.networks."10-mainif".matchConfig.Name}" tcp dport bgp counter accept comment "accept iBGP ${config.systemd.network.networks."10-mainif".matchConfig.Name}"
  # '';

}