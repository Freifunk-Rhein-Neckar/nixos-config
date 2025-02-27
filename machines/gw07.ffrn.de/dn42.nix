{ name, config, lib, pkgs, ... }:
{

  imports = [
    ../../roles/dn42-AS64946.nix
  ];

  services.freifunk.bird = {
    extraVariables = ''
      # define DN42_LOCAL_IP4 = ;
      # define DN42_LOCAL_IP6 = ;
    '';
    # localAdresses = [ ];
    extraConfig = ''
    '';
  };

  services.dn42peering = {
    enable = true;
    peerings = {
      "4242421084ic3" = {
        asn = 4242421084;
        addr_ipv6_local = "fe80::b";
        addr_ipv6_remote = "fe80::a";
        endpoint = "icvpn3.darmstadt.freifunk.net:64946";
        wg_key = "wg-icvpn3.darmstadt.freifunk.net.key";
        wg_pub = "CyAtV/8xHWFIppy35RHRD7d02rRIcNxLzTn4rm0zMlI=";
        listen_port = 21084;
      };
    };
  };

}