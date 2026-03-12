{ config, lib, pkgs, ... }:
{
  services.nginx = {
    enable = true;
    virtualHosts = {
      "idm.ffrn.de" =  {
        locations."/".return = "307 https://idm.ffrn.de$request_uri";
      };
    };
    streamConfig = ''
      upstream idm {
        server sso1.int.ffrn.de:444;
        # server sso1.ffrn.de:444;
        resolver 127.0.0.53:53 ipv4=on ipv6=on;
      }

      upstream cloud {
        # server cloud.ffrn.de:443;
        server cloud1.int.ffrn.de:444;
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
    '';
  };

  networking.firewall.allowedTCPPorts = [
    443
    80
  ];

}