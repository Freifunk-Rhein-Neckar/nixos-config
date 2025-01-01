{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.ffrn-gateway;

  gwNumber = lib.strings.toIntBase10(lib.strings.removePrefix "gw" config.networking.hostName);

  padString = (n: if n < 10 then "0" + toString n else toString n);

  mainif = "${config.systemd.network.networks."10-mainif".matchConfig.Name}";

in
{
  options.modules.ffrn-gateway = {
    enable = lib.mkEnableOption "Enable FFRN Gateway";

    publicIPv4 = lib.mkOption {
      type = types.str;
    };

    publicIPv6 = lib.mkOption {
      type = types.str;
    };

  };

  config = mkIf cfg.enable {
    networking.nftables.tables.postrouting.content = ''
      chain postrouting_extra {
        ip saddr 10.142.0.0/16 oifname "${mainif}" ip daddr != { 10.0.0.0/8, 172.16.0.0/12, 192.0.2.0/24, 192.168.0.0/16, 198.51.100.0/24, 203.0.113.0/24 } counter snat to ${cfg.publicIPv4};
      }
    '';

    systemd.network.networks."10-mainif".address = [ "${cfg.publicIPv6}" ];

    networking.firewall.extraInputRules = ''
      ip6 saddr 2a01:4f8:171:3242::/64 udp dport 4789 counter accept comment "accept vxlan from elsenz"
      ip6 saddr 2a01:4f8:140:4093::/64 udp dport 4789 counter accept comment "accept vxlan from itter"
      ip6 saddr 2a01:4f8:160:624c::/64 udp dport 4789 counter accept comment "accept vxlan from weschnitz"
    '';

    services.freifunk.bird = {
      routerId = cfg.publicIPv4;
      localAdresses = [
        cfg.publicIPv4
        cfg.publicIPv6
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
                krt_prefsrc = ${cfg.publicIPv4};
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
                krt_prefsrc = ${cfg.publicIPv6};
                accept;
              }
              accept;
            };
          };
        }
      '';
    };

    modules.freifunk.gateway = {
      outInterfaces = [ "${mainif}" ];
      vxlan = {
        local = cfg.publicIPv6;
        remoteLocals = lib.filter (ip: ip != config.modules.freifunk.gateway.vxlan.local) [
          "2a01:4f8:140:4093::ff2:2"              # gw02.ffrn.de
          "2a01:4f8:171:3242::ff1:3"              # gw03.ffrn.de
          "2a01:4f8:140:4093::ff2:4"              # gw04.ffrn.de
          "2a01:4f8:160:624c::ff3:5"              # gw05.ffrn.de
          "2a01:4f8:160:624c::ff3:6"              # gw06.ffrn.de
          "2a01:4f8:140:4093::ff2:7"              # gw07.ffrn.de
          "2a01:4f8:160:624c::ff3:8"              # gw08.ffrn.de
          "2a01:4f8:171:3242::ff1:9"              # gw09.ffrn.de
          "2a01:4f8:160:624c:5054:ff:fed1:ebc5"   # map1.ffrn.de
          "2a01:4f8:160:624c:5054:ff:fe37:2749"   # resolver1.ffrn.de
          "2a01:4f8:140:4093:0:c0ff:fea8:7b21"    # resolver2.ffrn.de
          "2a01:4f8:160:624c:5054:ff:fe62:3d89"   # unifi.ffrn.de
        ];
      };
      domains = {
        dom0 = {
          batmanAdvanced = {
            mac = "6a:ff:94:00:${padString gwNumber}:02";
          };
          ipv4 = {
            prefixes = {
              "10.142.0.0/16" = {
                addresses = [
                  "10.142.0.${toString gwNumber}"
                ];
              };
            };
          };
          ipv6 = {
            prefixes = {
              "2a01:4f8:171:fcff::/64" = {
                addresses = [
                  "2a01:4f8:171:fcff::${toString gwNumber}"
                ];
              };
              "2a01:4f8:140:7700::/64" = {
                addresses = [
                  "2a01:4f8:140:7700::${toString gwNumber}"
                ];
              };
              "2a01:4f8:160:9700::/64" = {
                addresses = [
                  "2a01:4f8:160:9700::${toString gwNumber}"
                ];
              };
              "fdc3:67ce:cc7e:9001::/64" = {
                addresses = [
                  "fdc3:67ce:cc7e:9001::${toString gwNumber}"
                ];
              };
            };
          };
        };
      };
    };
  };
}
