{ config, lib, ... }:
let

  mainifname = config.systemd.network.links."10-mainif".linkConfig.Name;

in {

  imports = [
    ../modules/chrony.nix
  ];

  networking.firewall.extraForwardRules = lib.mkOrder 10 ''
    # drop a bunch of ranges which will only result in Abuse Notifications
    oifname "${mainifname}" ip daddr 0.0.0.0/8 counter drop comment "RFC 1122 'this' network"
    oifname "${mainifname}" ip daddr 10.0.0.0/8 counter drop comment "RFC 1918 private space"
    oifname "${mainifname}" ip daddr 100.64.0.0/10 counter drop comment "RFC 6598 Carrier grade nat space"
    oifname "${mainifname}" ip daddr 127.0.0.0/8 counter drop comment "RFC 1122 localhost"
    oifname "${mainifname}" ip daddr 169.254.0.0/16 counter drop comment "RFC 3927 link local"
    oifname "${mainifname}" ip daddr 172.16.0.0/12 counter drop comment "RFC 1918 private space "
    oifname "${mainifname}" ip daddr 192.168.0.0/16 counter drop comment "RFC 1918 private space"
    oifname "${mainifname}" ip daddr 192.0.0.0/24 counter drop comment "IETF Protocol Assignments"
    oifname "${mainifname}" ip daddr 192.0.2.0/24 counter drop comment "RFC 5737 TEST-NET-1"
    oifname "${mainifname}" ip daddr 192.88.99.0/24 counter drop comment "RFC 7526 6to4 anycast relay"
    oifname "${mainifname}" ip daddr 192.168.0.0/16 counter drop comment "RFC 1918 private space"
    oifname "${mainifname}" ip daddr 198.18.0.0/15 counter drop comment "RFC 2544 benchmarking"
    oifname "${mainifname}" ip daddr 198.51.100.0/24 counter drop comment "RFC 5737 TEST-NET-2"
    oifname "${mainifname}" ip daddr 203.0.113.0/24 counter drop comment "RFC 5737 TEST-NET-3"
    oifname "${mainifname}" ip daddr 240.0.0.0/4 counter drop comment "reserved"
    oifname "${mainifname}" ip daddr { 6.0.0.0/7, 11.0.0.0/8, 21.0.0.0-22.255.255.255, 26.0.0.0/8 } counter drop comment "DoD 1"
    oifname "${mainifname}" ip daddr { 28.0.0.0-30.255.255.255, 33.0.0.0/8, 55.0.0.0/8, 214.0.0.0/7 } counter drop comment "DoD 2"
    oifname "${mainifname}" ip daddr 25.0.0.0/8 counter drop comment "UK Ministry of Defence"
    oifname "${mainifname}" ip6 saddr fc00::/7 counter drop comment "RFC 4193 Unique Local Unicast"
    oifname "${mainifname}" ip6 daddr fc00::/7 counter drop comment "RFC 4193 Unique Local Unicast"
    oifname "${mainifname}" ip6 daddr 64:ff9b::/96 counter drop comment "RFC 6052 NAT64"
  '';

}
