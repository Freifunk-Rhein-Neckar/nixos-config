{ name, config, lib, pkgs, ... }:
{

  networking.firewall.extraInputRules = ''
    iifname "enp1s0" ip6 saddr fe80::/64 ip6 daddr { ff02::5, ff02::6 } meta l4proto 89 counter accept comment "allow OSPV v3 in on enp1s0"
  '';

  networking.nftables.tables.postrouting.content = ''
    chain postrouting_extra {
      ip saddr 10.142.0.0/16 oifname "enp1s0" counter snat to 138.201.30.244
    }
  '';

  services.freifunk.bird = {
    routerId = "138.201.30.244";
    localAdresses = [
      "138.201.30.244"
    ];
    extraConfig = ''

      define PEERING_NET4 = [
        192.168.128.0/24            # ffrnix
      ];

      define PEERING_NET6 = [
        2a01:4f8:171:fcfd::/64,     # ffrnix
        2a01:4f8:171:fcfc::/64      # twoix
      ];
      
      protocol direct d_domains {
        interface "bat-dom*";
        ipv4 {
            import all;
        };
        ipv6 {
            import all;
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
      protocol ospf v3 ffv4 {
        ipv4 {
          import all;
          export filter {
            # include "/etc/bird/accept_LOCAL_NET4_set.conf";
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
          interface "enp1s0" {
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
          interface "enp1s0" {
            type broadcast;     # Detected by default
            cost 10;            # Interface metric
            hello 5;            # Default hello perid 10 is too long
          };

        };
      }
      protocol radv radv_dom0 {
        propagate routes no;

        ipv6 {
          table master6;
          export all;
          import none;
        };

        interface "bat-dom0" {
          min delay 3;
          max ra interval 60;
          other config no;
          solicited ra unicast yes;
          prefix 2a01:4f8:171:fcff::/64 { };
          prefix fdc3:67ce:cc7e:9001::/64 { };
          rdnss {
            ns fdc3:67ce:cc7e:53::a;
            ns fdc3:67ce:cc7e:53::b;
          };
          dnssl {
            domain "ffrn.de";
            domain "freifunk-rhein-neckar.de";
          };
          # account here for the encapsulation overhead of batman-adv v15
          link mtu 1280;

          # custom option type 38 value hex:0e:10:20:01:06:7c:29:60:64:64:00:00:00:00;
          # custom option type 38 value hex:0e:10:00:64:ff:9b:00:00:00:00:00:00:00:00;
        };

        prefix ::/0 {
          skip;
        };
      }

      protocol kernel k_main4 {
        persist;
        ipv4 {
          table master4;
          import none;
          export filter {
            if net !~ PEERING_NET4 then {
              krt_prefsrc = 138.201.30.244;
            }
            accept;
          };
        };
      }

      protocol kernel k_main6 {
        persist;
        ipv6 {
          table master6;
          import none;
          export filter {
            if net !~ PEERING_NET6 then {
              krt_prefsrc = 2a01:4f8:171:3242:0:8aff:fec9:1ef4;
              accept;
            }
            accept;
          };
        };
      }
    '';
  };

  modules.freifunk.gateway = {
    meta = {
      latitude = "50.478158406";
      longitude = "12.335886955";
    };
    vxlan = {
      local = "2a01:4f8:171:3242:0:8aff:fec9:1ef4";
      remoteLocals = [
        "2a01:4f8:140:4093:0:5eff:fe82:f3e8"    # gw02.ffrn.de
        "2a01:4f8:171:3242:0:8aff:fec9:1ef7"    # gw03.ffrn.de
        "2a01:4f8:160:624c:80af:beff:fee3:f047" # gw05.ffrn.de
        "2a01:4f8:140:4093:0:5eff:fe82:f3e9"    # gw04.ffrn.de
        "2a01:4f8:160:624c:5054:ff:fed2:43c1"   # gw06.ffrn.de
        "2a01:4f8:140:4093:0:5eff:fe82:f3eb"    # gw07.ffrn.de
        "2a01:4f8:160:624c:5054:ff:fe3f:c2ea"   # gw08.ffrn.de
        # "2a01:4f8:171:3242:0:8aff:fec9:1ef4"    # gw09.ffrn.de
        "2a01:4f8:160:624c:5054:ff:fed1:ebc5"   # map1.ffrn.de
        "2a01:4f8:160:624c:5054:ff:fe37:2749"   # resolver1.ffrn.de
        "2a01:4f8:140:4093:0:c0ff:fea8:7b21"    # resolver2.ffrn.de
        "2a01:4f8:160:624c:5054:ff:fe62:3d89"   # unifi.ffrn.de
      ];
    };
    domains = {
      dom0 = {
        batmanAdvanced = {
          mac = "6a:ff:94:00:09:02";
        };
        ipv4 = {
          dhcpV4 = {
            pools = [
              "10.142.128.1 - 10.142.131.254"
            ];
          };
          prefixes = {
            "10.142.0.0/16" = {
              addresses = [
                "10.142.0.9"
              ];
            };
          };
        };
        ipv6 = {
          prefixes = {
            "2a01:4f8:171:fcff::/64" = {
              addresses = [
                "2a01:4f8:171:fcff::9"
              ];
            };
            "2a01:4f8:140:7700::/64" = {
              addresses = [
                "2a01:4f8:140:7700::9"
              ];
            };
            "2a01:4f8:160:9700::/64" = {
              addresses = [
                "2a01:4f8:160:9700::9"
              ];
            };
            "fdc3:67ce:cc7e:9001::/64" = {
              addresses = [
                "fdc3:67ce:cc7e:9001::9"
              ];
            };
          };
        };
      };
    };
  };
}