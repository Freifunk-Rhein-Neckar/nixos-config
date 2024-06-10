{ name, nodes, config, pkgs, lib, ... }:
{
  
  networking.firewall.extraInputRules = ''
    iifname "enp1s0" ip6 saddr fe80::/64 ip6 daddr { ff02::5, ff02::6 } meta l4proto 89 counter accept comment "allow OSPV v3 in on enp1s0"
  '';


  services.freifunk.bird.extraConfig = ''
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
  '';

}