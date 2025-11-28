{ config, lib, pkgs, ... }:
{

  imports = [
    ./bridges-clffrn1.nix
    ./bridges-clffnix1.nix
  ];

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  services.bird = {
    enable = true;
    package = pkgs.bird3;
    config = ''
      log syslog all;

      router id 176.9.161.125;

      ipv4 table master4;
      ipv6 table master6;

      define PEERING_NET4 = [
          192.168.128.0/24            # ffrnix
      ];

      define PEERING_NET6 = [
          2a01:4f8:171:fcfd::/64,     # ffrnix
          2a01:4f8:171:fcfc::/64      # twoix
      ];

      define LOCAL_NET4 = [
          # 176.9.161.125/32,
          192.168.124.0/24+,
          88.198.106.115/32,
          88.198.112.217/32,
          88.198.112.218/32,
          88.198.112.220/32,
          88.198.112.221/32,
          88.198.112.222/32
      ];

      define LOCAL_NET6 = [
          2a01:4f8:160:624c::/64+,
          2a01:4f8:160:9700::/56+
      ];

      filter noroutes {
          reject;
      }

      filter allroutes {
              accept;
      }

      function accept_NET4_set (prefix set NET4; string filter_name) {
          if net ~ NET4 then {
              print "Accept (Proto: ", proto, "): ", net, " in ", filter_name ," ", bgp_path;
              accept;
          }
      }

      function accept_NET6_set (prefix set NET6; string filter_name) {
          if net ~ NET6 then {
              print "Accept (Proto: ", proto, "): ", net, " in ", filter_name ," ", bgp_path;
              accept;
          }
      }

      function reject_default_route6() {
          if net = ::/0 then {
              print "Reject (Proto: ", proto, "): ", net, " no default route allowed from ", from, " ", bgp_path;
              reject;
          }
      }
      function accept_default_route6() {
          if net = ::/0 then {
              # print "Accept (Proto: ", proto, "): ", net, " default route allowed from ", from, " ", bgp_path;
              accept;
          }
      }

      filter f_accept_default_route6 {
          accept_default_route6();
          reject;
      }

      function reject_default_route4() {
          if net = 0.0.0.0/0 then {
              print "Reject (Proto: ", proto, "): ", net, " no default route allowed from ", from, " ", bgp_path;
              reject;
          }
      }
      function accept_default_route4() {
          if net = 0.0.0.0/0 then {
              # print "Accept (Proto: ", proto, "): ", net, " default route allowed from ", from, " ", bgp_path;
              accept;
          }
      }

      filter f_accept_default_route4 {
          accept_default_route4();
          reject;
      }

      filter f_accept_local_net4 {
          accept_NET4_set(LOCAL_NET4, "LOCAL_NET4");
          reject;
      }

      filter f_accept_local_net6 {
          accept_NET6_set(LOCAL_NET6, "LOCAL_NET6");
          reject;
      }

      protocol device {
      }

      protocol kernel k_main4 {
          persist;
          kernel table 10;
          ipv4 {
              table master4;
              import none;
              export filter {
                  if net !~ PEERING_NET4 then {
                      krt_prefsrc = 176.9.161.125;
                  }
                  reject_default_route4();
                  accept;
              };
          };
      }

      protocol kernel k_main6 {
          persist;
          kernel table 10;
          ipv6 {
              table master6;
              import none;
              export filter {
                  reject_default_route6();
                  if net !~ PEERING_NET6 then {
                      accept;
                  }
                  accept;
              };
          };
      }


      # static routing on vmhosts

      ipv6 table elsenz6;
      ipv6 table itter6;
      ipv6 table weschnitz6;

      ipv4 table elsenz4;
      ipv4 table itter4;
      ipv4 table weschnitz4;

      # IPv6

      protocol static s_elsenz6 {
          route ::/0 via 2a01:4f8:171:fcfd::20:1;
          ipv6 {
              table elsenz6;
              import all;
              export none;
          };
      }

      protocol kernel k_elsenz6 {
          persist;
          kernel table 11;
          ipv6 {
              table elsenz6;
              export filter allroutes;
              import none;
          };
      }

      protocol static s_itter6 {
          route ::/0 via 2a01:4f8:171:fcfd::40:1;
          ipv6 {
              table itter6;
              import all;
              export none;
          };
      }

      protocol kernel k_itter6 {
          persist;
          kernel table 12;
          ipv6 {
              table itter6;
              export filter allroutes;
              import none;
          };
      }

      protocol static s_weschnitz6 {
          route ::/0 via fe80::1%${config.systemd.network.links."10-mainif".linkConfig.Name};
          ipv6 {
              table weschnitz6;
              import all;
              export none;
          };
      }

      protocol kernel k_weschnitz6 {
          persist;
          kernel table 13;
          ipv6 {
              table weschnitz6;
              export filter allroutes;
              import none;
          };
      }

      # IPv4

      protocol static s_elsenz4 {
          route 0.0.0.0/0 via 192.168.128.20;
          # route 0.0.0.0/0 via 2a01:4f8:171:fcfd::20:1;
          ipv4 {
              table elsenz4;
              import all;
              export none;
          };
      }

      protocol kernel k_elsenz4 {
          persist;
          kernel table 11;
          ipv4 {
              table elsenz4;
              export filter allroutes;
              import none;
          };
      }

      protocol static s_itter4 {
          route 0.0.0.0/0 via 192.168.128.40;
          # route 0.0.0.0/0 via 2a01:4f8:171:fcfd::40:1;
          ipv4 {
              table itter4;
              import all;
              export none;
          };
      }

      protocol kernel k_itter4 {
          persist;
          kernel table 12;
          ipv4 {
              table itter4;
              export filter allroutes;
              import none;
          };
      }

      protocol static s_weschnitz4 {
          route 0.0.0.0/0 via 176.9.161.121%${config.systemd.network.links."10-mainif".linkConfig.Name};
          ipv4 {
              table weschnitz4;
              import all;
              export none;
          };
      }

      protocol kernel k_weschnitz4 {
          persist;
          kernel table 13;
          ipv4 {
              table weschnitz4;
              export filter allroutes;
              import none;
          };
      }

      protocol direct d_ffrnix {
          interface "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}";
          ipv4 {
              import all;
          };
          ipv6 {
              import all;
          };
      }

      protocol direct d_twoix {
          interface "twoix";
          ipv4 {
              import all;
          };
          ipv6 {
              import all;
          };
      }

      protocol direct d_br_vm {
          interface "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}";
          ipv4 {
              import filter f_accept_local_net4;
          };
          ipv6 {
              import filter f_accept_local_net6;
          };
      }

      protocol ospf v3 ffv4 {
          ipv4 {
              import all;
              export filter {
                  accept_NET4_set(LOCAL_NET4, "LOCAL_NET4");
                  if source ~ [ RTS_STATIC ] then {
                      accept;
                  }
                  if proto ~ "d_dom*" then {
                      accept;
                  }
                  if proto = "d_dummy0" then {
                      print "Info (Proto: ", proto, "): ", net, " allowed ospf export dummy0 ", bgp_path;
                      accept;
                  }
                  print "Info (Proto: ", proto, "): ", net, " didn't pass filter ", bgp_path;
                  reject;
              };
          };
          area 0 {
              interface "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}" {
                  type broadcast;     # Detected by default
                  cost 20;            # Interface metric
                  hello 5;            # Default hello perid 10 is too long
              };
      #        interface "twoix" {
      #            type broadcast;     # Detected by default
      #            cost 40;            # Interface metric
      #            hello 5;            # Default hello perid 10 is too long
      #        };
              interface "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}" {
                  type broadcast;     # Detected by default
                  cost 10;            # Interface metric
                  hello 5;            # Default hello perid 10 is too long
              };
          };
      }

      protocol ospf v3 ffv6 {
          ipv6 {
              import all;
              export filter {
                  accept_NET6_set(LOCAL_NET6, "LOCAL_NET6");
                  if source ~ [ RTS_STATIC ] then {
                      accept;
                  }
                  if proto ~ "d_dom*" then {
                      accept;
                  }
                  if proto = "d_br_test6" then {
                      accept;
                  }
                  if proto = "d_dummy0" then {
                      print "Info (Proto: ", proto, "): ", net, " allowed ospf export dummy0 ", bgp_path;
                      accept;
                  }
                  print "Info (Proto: ", proto, "): ", net, " didn't pass filter ", bgp_path;
                  reject;
              };
          };
          area 0 {
              interface "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}" {
                  type broadcast;     # Detected by default
                  cost 10;            # Interface metric
                  hello 5;            # Default hello perid 10 is too long
              };
              interface "twoix" {
                  type broadcast;     # Detected by default
                  cost 20;            # Interface metric
                  hello 5;            # Default hello perid 10 is too long
              };
              interface "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}" {
                  type broadcast;     # Detected by default
                  cost 10;            # Interface metric
                  hello 5;            # Default hello perid 10 is too long
              };
          };
      }

      protocol direct d_dummy0 {
          interface "dummy0";
          ipv4 {
              import filter {
                      print "Info (Proto: ", proto, "): ", net, " allowed due to dummy0", bgp_path;
                      accept;
              };
          };
          ipv6 {
              import filter {
                      print "Info (Proto: ", proto, "): ", net, " allowed due to dummy0 ", bgp_path;
                      accept;
              };
          };
      }

      protocol static s_main6 {
          route ::/0 via fe80::1%${config.systemd.network.links."10-mainif".linkConfig.Name};
          route 2a01:4f8:160:9700::/56 unreachable;
          route 2a01:4f8:160:97c0::/60 via 2a01:4f8:160:624c:5054:ff:fe6b:6397; # gw-test01

          ipv6 {
              import all;
              export none;
          };
      }

      protocol static s_main4 {
          route 0.0.0.0/0 via 176.9.161.121%${config.systemd.network.links."10-mainif".linkConfig.Name};
          #route 88.198.112.218/32 via "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}"; # forum

          ipv4 {
              import all;
              export none;
          };
      }
    '';
  };

  systemd.network.netdevs."25-ffrnix" = {
    netdevConfig = {
      Name = "ffrnix";
      Kind = "vlan";
      MTUBytes = 1500;
    };
    vlanConfig.Id = 4006;
  };
  systemd.network.networks."25-ffrnix" = {
    matchConfig.Name = config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name;
    networkConfig = {
      IPv6AcceptRA = false;
    };
    address = [
      "192.168.128.10/24"
      "2a01:4f8:171:fcfd::10:1/64"
    ];
  };

  systemd.network.networks."10-mainif".networkConfig.VLAN = [ config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name ];

  systemd.network.netdevs."71-br-vm" = {
    netdevConfig = {
      Name = "br-vm";
      Kind = "bridge";
    };
  };
  systemd.network.netdevs."80-dummy-br-vm" = {
    netdevConfig = {
      Name = "dummy-br-vm";
      Kind = "dummy";
    };
  };

  systemd.network.networks."80-dummy-br-vm" = {
    matchConfig.Name = config.systemd.network.netdevs."80-dummy-br-vm".netdevConfig.Name;
    networkConfig.Bridge = config.systemd.network.netdevs."71-br-vm".netdevConfig.Name;
  };

  systemd.network.networks."71-br-vm" = {
    matchConfig = {
      Name = "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}";
    };
    addresses = [
      {
        Address = "192.168.124.1/24";
      }
    ];
    networkConfig = {
      EmitLLDP = true;
      DHCP = "no";
      IPv6AcceptRA = false;
      IPv6SendRA = true;
      IPv6Forwarding = true;
      DHCPServer = true;
    };
    ipv6Prefixes = [
      {
        Prefix = "2a01:4f8:160:624c::/64";
        Assign = true;
        Token = "::3";
      }
    ];
    dhcpServerConfig = {
#      ServerAddress = "0.0.0.0/24";
    };
    routingPolicyRules = [
      {
        Family = "both";
        Table = 10;
        Priority = 31000;
      }
      {
        Family = "ipv6";
        From = "2a01:4f8:171:fc00::/56";
        Table = 11;
        Priority = 31010;
      }
      {
        Family = "ipv6";
        From = "2a01:4f8:140:7700::/56";
        Table = 12;
        Priority = 31020;
      }
      {
        Family = "ipv6";
        From = "2a01:4f8:160:9700::/56";
        Table = 13;
        Priority = 31030;
      }
      {
        Family = "ipv4";
        From = "138.201.30.242/32";
        Table = 11;
        Priority = 31011;
      }
      {
        Family = "ipv4";
        From = "138.201.30.243/32";
        Table = 11;
        Priority = 31012;
      }
      {
        Family = "ipv4";
        From = "138.201.30.244/32";
        Table = 11;
        Priority = 31013;
      }
      {
        Family = "ipv4";
        From = "138.201.30.247/32";
        Table = 11;
        Priority = 31014;
      }
      {
        Family = "ipv4";
        From = "138.201.30.254/32";
        Table = 11;
        Priority = 31015;
      }
      {
        Family = "ipv4";
        From = "138.201.44.141/32";
        Table = 11;
        Priority = 31016;
      }
      {
        Family = "ipv4";
        From = "94.130.243.232/29";
        Table = 12;
        Priority = 31020;
      }
      {
        Family = "ipv4";
        From = "88.198.106.115/32";
        Table = 13;
        Priority = 31031;
      }
      {
        Family = "ipv4";
        From = "88.198.112.217/32";
        Table = 13;
        Priority = 31032;
      }
      {
        Family = "ipv4";
        From = "88.198.112.218/32";
        Table = 13;
        Priority = 31033;
      }
      {
        Family = "ipv4";
        From = "88.198.112.220/32";
        Table = 13;
        Priority = 31034;
      }
      {
        Family = "ipv4";
        From = "88.198.112.221/32";
        Table = 13;
        Priority = 31035;
      }
      {
        Family = "ipv4";
        From = "88.198.112.222/32";
        Table = 13;
        Priority = 31036;
      }
    ];
  };

  networking.firewall.interfaces."${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}".allowedUDPPorts = [ 67 ];

  networking.firewall.filterForward = false;
  networking.firewall.checkReversePath = false;
  networking.firewall.logRefusedConnections = false;

  networking.nftables.tables.nixos-fw = {
    content = ''
      chain input_extra {}
      chain forward_extra {}

      ${lib.optionalString (!config.networking.firewall.filterForward) ''
      chain forward {
        type filter hook forward priority filter; policy drop;

        jump forward-allow
      }

      chain forward-allow {
        icmpv6 type != { router-renumbering, 139 } accept comment "Accept all ICMPv6 messages except renumbering and node information queries (type 139).  See RFC 4890, section 4.3."
        ${config.networking.firewall.extraForwardRules}
      }''}
    '';
    family = "inet";
  };

    networking.nftables.tables.postrouting = {
    content = ''
      chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
        ip saddr { 192.168.124.0/24 } oifname "${config.systemd.network.links."10-mainif".linkConfig.Name}" counter masquerade
        ip saddr { 192.168.124.0/24 } counter masquerade
      }
    '';
    family = "inet";
  };

  networking.firewall.extraForwardRules = lib.mkMerge [
    (lib.mkOrder 500 ''
      ip saddr 192.168.124.0/24 iifname "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}" oifname "${config.systemd.network.links."10-mainif".linkConfig.Name}" counter accept
      ip daddr 192.168.124.0/24 iifname "${config.systemd.network.links."10-mainif".linkConfig.Name}" oifname "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}" counter accept
      ip6 saddr 2a01:4f8:160:624c::/64 iifname "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}" oifname "${config.systemd.network.links."10-mainif".linkConfig.Name}" counter accept
      ip6 daddr 2a01:4f8:160:624c::/64 iifname "${config.systemd.network.links."10-mainif".linkConfig.Name}" oifname "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}" counter accept

      ip6 saddr { 2a01:4f8:171:3242::/64, 2a01:4f8:171:fc00::/56 } iifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip6 daddr { 2a01:4f8:171:3242::/64, 2a01:4f8:171:fc00::/56 } iifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip6 saddr { 2a01:4f8:140:4093::/64, 2a01:4f8:140:7700::/56 } iifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip6 daddr { 2a01:4f8:140:4093::/64, 2a01:4f8:140:7700::/56 } iifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip6 saddr { 2a01:4f8:160:624c::/64, 2a01:4f8:160:9700::/56 } iifname { "${config.systemd.network.links."10-mainif".linkConfig.Name}", "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.links."10-mainif".linkConfig.Name}", "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip6 daddr { 2a01:4f8:160:624c::/64, 2a01:4f8:160:9700::/56 } iifname { "${config.systemd.network.links."10-mainif".linkConfig.Name}", "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.links."10-mainif".linkConfig.Name}", "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip saddr { 138.201.30.242, 138.201.30.243, 138.201.30.244, 138.201.30.247, 138.201.30.254, 138.201.44.141 } iifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip daddr { 138.201.30.242, 138.201.30.243, 138.201.30.244, 138.201.30.247, 138.201.30.254, 138.201.44.141 } iifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip saddr 94.130.243.232/29 iifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip daddr 94.130.243.232/29 iifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip saddr { 88.198.106.115, 88.198.112.217, 88.198.112.218, 88.198.112.220, 88.198.112.221, 88.198.112.222 } iifname { "${config.systemd.network.links."10-mainif".linkConfig.Name}", "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.links."10-mainif".linkConfig.Name}", "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip daddr { 88.198.106.115, 88.198.112.217, 88.198.112.218, 88.198.112.220, 88.198.112.221, 88.198.112.222 } iifname { "${config.systemd.network.links."10-mainif".linkConfig.Name}", "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.links."10-mainif".linkConfig.Name}", "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip6 saddr 64:ff9b::/96 iifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip6 daddr 64:ff9b::/96 iifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip6 saddr fdc3:67ce:cc7e::/48 iifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip6 daddr fdc3:67ce:cc7e::/48 iifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip saddr 192.168.120.0/21 iifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip daddr 192.168.120.0/21 iifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip saddr 192.168.128.0/22 iifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      ip daddr 192.168.128.0/22 iifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
      iifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } oifname { "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}", "twoix", "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}", "br-test6" } counter accept
    '')
    (lib.mkOrder 9000 ''
      counter comment "count packets"
    '')
  ];

  networking.firewall.extraInputRules = ''
    iifname "${config.systemd.network.netdevs."25-ffrnix".netdevConfig.Name}" ip6 saddr fe80::/64 ip6 daddr { ff02::5, ff02::6 } meta l4proto ospfigp counter accept comment "allow OSPV v3 in on ffrnix"
    iifname "twoix" ip6 saddr fe80::/64 ip6 daddr { ff02::5, ff02::6 } meta l4proto ospfigp counter accept comment "allow OSPV v3 in on twoix"
    iifname "${config.systemd.network.netdevs."71-br-vm".netdevConfig.Name}" ip6 saddr fe80::/64 ip6 daddr { ff02::5, ff02::6 } meta l4proto ospfigp counter accept comment "allow OSPV v3 in on br-vm"
  '';

}
