{ config, lib, pkgs, ... }:
let
  domain = "idm.ffrn.de";
  acmeDomain = "${config.networking.hostName}.${config.networking.domain}";
in {

  imports = [
    ./acme.nix
    ./nginx.nix
  ];

  security.acme.certs."${acmeDomain}" = {
    extraDomainNames = [
      "${domain}"
    ];
    reloadServices = [ "kanidm" ];
  };

  systemd.services.kanidm = {
    after = [ "acme-${acmeDomain}.service" ];
    wants = [ "acme-${acmeDomain}.service" ];
    serviceConfig.SupplementaryGroups = [ "acme" ];
  };

  services.kanidm = {
    enableClient = true;
    enableServer = true;

    package = pkgs.kanidm_1_9;

    clientSettings = {
      uri = "https://${domain}";
    };

    serverSettings = {
      inherit domain;
      origin = "https://${domain}";
      bindaddress = "[::1]:8443";
      ldapbindaddress = "[::]:3636";
      trust_x_forward_for = true;
      tls_key = config.security.acme.certs."${acmeDomain}".directory + "/key.pem";
      tls_chain = config.security.acme.certs."${acmeDomain}".directory + "/fullchain.pem";
      online_backup = {
        path = "/var/lib/kanidm/backups/";
        schedule = "@daily";
        versions = 90;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 3636 443 80 ];
  networking.firewall.allowedUDPPorts = [ 443 ];

  services.nebula.networks."ffrn".firewall.inbound = lib.optional (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) {
    host = "any";
    port = 444;
    proto = "tcp";
    groups = [ "noc" "web" ];
  };

  networking.firewall.extraInputRules = ''
    ${ if (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) then ''
      iifname "${config.services.nebula.networks."ffrn".tun.device}" tcp dport 444 counter accept comment "nginx: kanidm: accept from nebula"
    '' else ""}
  '';

  services.nginx = {
    enable = true;
    upstreams.kanidm = {
      servers = {
        "${config.services.kanidm.serverSettings.bindaddress}" = { };
      };
    };
    virtualHosts."${domain}" = {
      extraConfig = ''
        set_real_ip_from 192.168.100.0/24;
        real_ip_header proxy_protocol;
        listen [::]:444 ssl proxy_protocol;
        listen 0.0.0.0:444 ssl proxy_protocol;
      '';
      forceSSL = true;
      useACMEHost = acmeDomain;

      locations."/" = {
        proxyPass = "https://kanidm";
      };
    };
  };

}

