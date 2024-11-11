{ config, pkgs, name, ... }:
{
  services.knot = {
    enable = true;
    settings = {
      "server" = {
        "listen" = [
          "127.0.0.1@53"
          "::1@53"
          "89.58.15.197@53"
          "2a03:4000:60:11f::1@53"
        ];
      };
      remote.master_ns1 = {
        address = [
          "138.201.30.254"
          "2a01:4f8:171:3242::72"
        ];
        key = "tsig_ffrn_ns_2020052100";
      };
      log.syslog.any = "info";
      acl.acl_ns1 = {
        address = config.services.knot.settings.remote.master_ns1.address;
        key = config.services.knot.settings.remote.master_ns1.key;
        action = "notify";
      };
      template.default = {
        file = "%s.zone";
        storage = "/var/lib/knot/zones";
        master = "master_ns1";
        acl = "acl_ns1";
      };
      zone ={
        "f.b.e.0.7.0.1.b.e.0.a.2.ip6.arpa" = {};
        "ffrn.de" = {};
        "freifunk-rhein-neckar.de" = {};
        "ffbw.de" = {};
        "ffrn.net" = {};
        "ffwhm.de" = {};
        "freifunk-bw.de" = {};
        "freifunk-heidelberg.de" = {};
        "freifunk-ludwigshafen.de" = {};
        "freifunk-mannheim.de" = {};
        "freifunk-odenwald.de" = {};
        "freifunk-weinheim.de" = {};
        "rhein-neckar.freifunk.net" = {};
        "nodes.ffrn.de" = {};
        "in.ffrn.de" = {};
        "int.ffrn.de" = {};
      };
    };
    keyFiles = [
      config.age.secrets."tsig".path
    ];
  };

  networking.firewall.extraInputRules = ''
    udp dport 53 counter accept comment "knot: accept dns"
    tcp dport 53 counter accept comment "knot: accept dns"
  '';

  age.secrets."tsig" = {
    file = ../../secrets/${name}/tsig.age;
    mode = "0400";
    owner = "knot";
    group = "knot";
  };

}