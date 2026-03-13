{ config, lib, pkgs, ... }:
{
  services.nginx = {
    enable = true;
    virtualHosts = {
      "idm.ffrn.de" =  {
        locations."/".return = "307 https://$host$request_uri";
      };
      "cloud.ffrn.de" =  {
        locations."/".return = "307 https://$host$request_uri";
      };
      "tickets.ffrn.de" =  {
        locations."/".return = "307 https://$host$request_uri";
      };
      "map.ffrn.de" =  {
        locations."/".return = "307 https://$host$request_uri";
        serverAliases = [
          "m.ffrn.de"
          "map.freifunk-rhein-neckar.de"
          "tiles.ffrn.de"
        ];
      };
    };
    streamConfig = ''
      upstream idm {
        server sso1.int.ffrn.de:444;
        resolver 127.0.0.53:53 ipv4=on ipv6=on;
      }

      upstream cloud {
        server cloud1.int.ffrn.de:444;
        resolver 127.0.0.53:53 ipv4=on ipv6=on;
      }
      upstream tickets {
        # server tickets.int.ffrn.de:444;
        server 192.168.100.34:444;
        resolver 127.0.0.53:53 ipv4=on ipv6=on;
      }

      upstream map1 {
        # server map1.int.ffrn.de:444;
        server 192.168.100.36:444;
        resolver 127.0.0.53:53 ipv4=on ipv6=on;
      }

      server {
        listen 443;
        proxy_pass idm;
        proxy_protocol on;
        ssl_preread on;
        server_name idm.ffrn.de;
      }

      server {
        listen 443;
        proxy_pass cloud;
        proxy_protocol on;
        ssl_preread on;
        server_name cloud.ffrn.de;
      }

      server {
        listen 443;
        proxy_pass tickets;
        proxy_protocol on;
        ssl_preread on;
        server_name tickets.ffrn.de;
      }

      server {
        listen 443;
        proxy_pass map1;
        proxy_protocol on;
        ssl_preread on;
        server_name map.ffrn.de;
        server_name m.ffrn.de;
        server_name map.freifunk-rhein-neckar.de;
        server_name tiles.ffrn.de;
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [
    443
    80
  ];

}