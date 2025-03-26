{ config, lib, pkgs, ... }:

let
  cfg = config.services.dn42peering;
in
{
  options = {
    services.dn42peering = {
      enable = lib.mkEnableOption "Enable the peering service.";

      peerings = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule({ name, ...}:
        let
          pcfg = cfg.peerings.${name};
        in {
          options = {
            asn = lib.mkOption {
              type = lib.types.int;
              description = "Autonomous System Number (ASN).";
            };
            ifname = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "Interface name for the peering service.";
            };
            addr_ipv4_local = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Local IPv4 address.";
            };
            addr_ipv4_remote = lib.mkOption {
              type = lib.types.str;
              # default = "";
              description = "Remote IPv4 address.";
            };
            addr_ipv6_local = lib.mkOption {
              type = lib.types.str;
              description = "Local IPv6 address.";
            };
            addr_ipv6_remote = lib.mkOption {
              type = lib.types.str;
              description = "Remote IPv6 address.";
            };
            endpoint = lib.mkOption {
              type = lib.types.str;
              description = "Endpoint for the peering service.";
            };
            wg_key = lib.mkOption {
              type = lib.types.str;
            };
            wg_pub = lib.mkOption {
              type = lib.types.str;
              description = "WireGuard public key of the remote.";
            };
            listen_port = lib.mkOption {
              type = lib.types.int;
              description = "WireGuard listen port.";
            };
            disable_v4 = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Disable IPv4 channel";
            };
            prepend_count = lib.mkOption {
              type = lib.types.int;
              default = 0;
              description = "Number of times to prepend bgp_path.";
            };
            bgp_local_pref = lib.mkOption {
              type = lib.types.int;
              default = 100;
              description = "Local preference for BGP.";
            };
          };
        }
        ));
      };
    };
  };

  imports = [
    ./roa.nix
  ];

  config = lib.mkIf cfg.enable {

    systemd.network = lib.mkMerge (lib.attrValues (lib.mapAttrs (_: peering: {
      netdevs = {
        "60-${peering.ifname}" = {
          netdevConfig = {
            Name = "${peering.ifname}";
            Kind = "wireguard";
          };
          wireguardConfig = {
            ListenPort = peering.listen_port;
            PrivateKeyFile = "${config.age.secrets."${peering.wg_key}".path}";
          };
          wireguardPeers = [
            {
              PublicKey = "${peering.wg_pub}";
              AllowedIPs = [ "0.0.0.0/0" "::/0" ];
              Endpoint = "${peering.endpoint}";
              PersistentKeepalive = 25;
            }
          ];
        };
      };
      networks = {
        "60-${peering.ifname}" = {
          matchConfig = {
            Name = "${config.systemd.network.netdevs."60-${peering.ifname}".netdevConfig.Name}";
          };
          networkConfig = {
            IPv4ReversePathFilter = "no";
            IPv4Forwarding = "yes";
            IPv6Forwarding = "yes";
            KeepConfiguration = "yes";
          };
          addresses = [
            { Address = "${peering.addr_ipv6_local}/128"; Scope = "link"; Peer="${peering.addr_ipv6_remote}/128"; }
            (lib.mkIf (peering.addr_ipv4_local != "") { Address = "${peering.addr_ipv4_local}/32"; Scope = "link"; Peer="${peering.addr_ipv4_remote}/32";})
          ];
        };
      };
    }) cfg.peerings) ++ [{
      config.networkConfig = {
        IPv4Forwarding = true;
        IPv6Forwarding = true;
      };
    }]);

    networking.firewall.checkReversePath = lib.mkForce false; # TODO: don't override but set something
    networking.firewall.filterForward = false;
    networking.nftables.tables.nixos-fw = {
      content = ''
      ${lib.optionalString (!config.networking.firewall.filterForward) ''
      chain forward {
        type filter hook forward priority filter; policy drop;

        jump forward-allow
      }

      chain forward-allow {
        icmpv6 type != { router-renumbering, 139 } accept comment "Accept all ICMPv6 messages except renumbering and node information queries (type 139).  See RFC 4890, section 4.3."
        ct status dnat accept comment "allow port forward"
        ${config.networking.firewall.extraForwardRules}
      }
      ''}'';
      family = "inet";
    };

    networking.firewall.extraInputRules = ''
      ${lib.concatStringsSep "\n  " (lib.mapAttrsToList (_: peering: ''
      iifname "${config.systemd.network.netdevs."60-${peering.ifname}".netdevConfig.Name}" tcp dport bgp counter accept comment "accept BGP ${peering.ifname}"
      udp dport ${toString config.systemd.network.netdevs."60-${peering.ifname}".wireguardConfig.ListenPort} counter accept comment "accept wireguard (${config.systemd.network.netdevs."60-${peering.ifname}".netdevConfig.Name})"
      '') cfg.peerings)}
    '';

    age.secrets = builtins.listToAttrs (lib.mapAttrsToList (name: peering: {
      name = "${peering.wg_key}";
      value = {
        file = ../../secrets/${config.networking.hostName}/${peering.wg_key}.age;
        mode = "0640";
        owner = "root";
        group = "systemd-network";
      };
    }) cfg.peerings);

    services.freifunk.bird.extraFunctions = ''
      function is_valid_network_v4() -> bool {
        return net ~ [
          172.20.0.0/14{21,29}, # dn42
          172.20.0.0/24{28,32}, # dn42 Anycast
          172.21.0.0/24{28,32}, # dn42 Anycast
          172.22.0.0/24{28,32}, # dn42 Anycast
          172.23.0.0/24{28,32}, # dn42 Anycast
          # 172.31.0.0/16+,       # ChaosVPN
          # 10.100.0.0/14+,       # ChaosVPN
          # 10.127.0.0/16{16,32}, # neonetwork
          10.0.0.0/8{15,24}     # Freifunk.net
        ];
      }
      function is_valid_network_v6() -> bool {
        return net ~ [
          fd00::/8{44,64} # ULA address space as per RFC 4193
        ];
      }
      function is_ula() -> bool {
        return net ~ [
          fd00::/8+
        ];
      }
    '';

    services.freifunk.bird.extraConfig = ''
      ${lib.concatStringsSep "\n  " (lib.mapAttrsToList (_: peering: ''
      protocol bgp bgp_${peering.ifname} {
        local ${peering.addr_ipv6_local} as DN42_AS;
        neighbor ${peering.addr_ipv6_remote} as ${toString peering.asn};
        interface "${config.systemd.network.netdevs."60-${peering.ifname}".netdevConfig.Name}";

        default bgp_local_pref ${toString peering.bgp_local_pref};

        ipv6 {
          # table dn426;
          import keep filtered;

          import filter {
            if net ~ [
              fdc3:67ce:cc7e::/48+, # FFRN ULA Space
              fd34:fe56:7891::/48+  # FFRN Management ULA Space
            ] then reject;

            if !is_valid_network_v6() then {
              # print "[dn42_6] Invalid network: ", net;
              reject;
            }

            if (roa_check(dn42_roa_v6, net, bgp_path.last) != ROA_VALID) then {
              # Reject when unknown or invalid according to ROA
              print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
              reject;
            } else accept;
          };
          export filter {
            if net ~ [ fdc3:67ce:cc7e::/48 ] then accept;

            if !is_valid_network_v6() then {
              # print "[dn42_6] Invalid network: ", net;
              reject;
            }

            if (roa_check(dn42_roa_v6, net, bgp_path.last) != ROA_VALID) then {
              # Reject when unknown or invalid according to ROA
              print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
              reject;
            } else {
              ${lib.concatStringsSep "\n" (lib.strings.genList (_: "bgp_path.prepend(DN42_AS);") peering.prepend_count)}
              accept;
            }
          };
        };
        ${if !peering.disable_v4 then ''
        ipv4 {
          # table dn424;
          import keep filtered;

          import filter {
            if net ~ [ 10.142.0.0/16+ ] then reject;

            if !is_valid_network_v4() then {
              # print "[dn42_4] Invalid network: ", net;
              reject;
            }

            if (roa_check(dn42_roa_v4, net, bgp_path.last) != ROA_VALID) then {
              # Reject when unknown or invalid according to ROA
              print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
              reject;
            } else accept;
            # reject;
          };
          export filter {
            if net ~ [ 10.142.0.0/16 ] then accept;

            if !is_valid_network_v4() then {
              # print "[dn42_4] Invalid network: ", net;
              reject;
            }

            if (roa_check(dn42_roa_v4, net, bgp_path.last) != ROA_VALID) then {
              # Reject when unknown or invalid according to ROA
              print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
              reject;
            } else {
              ${lib.concatStringsSep "\n" (lib.strings.genList (_: "bgp_path.prepend(DN42_AS);") peering.prepend_count)}
              accept;
            }
          };
          extended next hop on;
        };
      '' else ""}
      };
      '') cfg.peerings)}
    '';
  };
}
