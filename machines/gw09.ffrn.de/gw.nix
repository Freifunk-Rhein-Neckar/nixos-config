{ name, config, lib, pkgs, ... }:
{

  imports = [
    ../../roles/gw/hetzner-vm.nix
  ];

  networking.nftables.tables.postrouting.content = ''
    chain postrouting_extra {
      ip saddr 10.142.0.0/16 oifname "enp1s0" counter snat to 138.201.30.244
    }
  '';

  services.freifunk.bird = {
    routerId = "138.201.30.244";
    localAdresses = [
      "138.201.30.244"
      "2a01:4f8:171:3242::ff1:9"
    ];
    extraConfig = ''

      define PEERING_NET4 = [
        192.168.128.0/24            # ffrnix
      ];

      define PEERING_NET6 = [
        2a01:4f8:171:fcfd::/64,     # ffrnix
        2a01:4f8:171:fcfc::/64      # twoix
      ];

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
              announce = true;
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