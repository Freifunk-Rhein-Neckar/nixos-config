{ config, lib, pkgs, ... }:
{
  services.nginx = {
    enable = true;
    virtualHosts = {
      "web1.ffrn.de" =  {
        default = true;
        locations."/".return = "307 https://$host$request_uri";
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
        server tickets1.int.ffrn.de:444;
        resolver 127.0.0.53:53 ipv4=on ipv6=on;
      }

      upstream map {
        server map1.int.ffrn.de:444;
        resolver 127.0.0.53:53 ipv4=on ipv6=on;
      }

      upstream forum {
        server forum1.int.ffrn.de:444;
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
        proxy_pass map;
        proxy_protocol on;
        ssl_preread on;
        server_name map.ffrn.de;
        server_name m.ffrn.de;
        server_name map.freifunk-rhein-neckar.de;
        server_name tiles.ffrn.de;
      }
      server {
        listen 443;
        proxy_pass forum;
        proxy_protocol on;
        ssl_preread on;
        server_name forum.ffrn.de;
        server_name faq.ffrn.de;
        server_name forum.freifunk-rhein-neckar.de;
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [
    443
    80
  ];

}