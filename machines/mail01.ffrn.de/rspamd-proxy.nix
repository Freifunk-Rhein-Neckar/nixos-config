{ config, lib, pkgs, ... }:
let
  rspamd_domain = "rspamd.ffrn.de";
  oauth2_proxy_domain = "mail01.ffrn.de";
in
{
  imports = [
    ../../modules/nginx.nix
  ];

  security.acme.certs."${config.networking.hostName}.${config.networking.domain}" = {
    extraDomainNames = [
      "rspamd.int.ffrn.de"
      "rspamd.ffrn.de"
    ];
  };

  services.nginx.virtualHosts."mail01.ffrn.de" = {
    forceSSL = true;
    useACMEHost = "${config.networking.hostName}.${config.networking.domain}";
  };

  services.nginx.virtualHosts."mail01.int.ffrn.de" = {
    forceSSL = true;
    useACMEHost = "${config.networking.hostName}.${config.networking.domain}";
  };

  services.nginx.virtualHosts."${rspamd_domain}" = {
    serverAliases = [ "rspamd.int.ffrn.de" ];
    locations."/" = {
      proxyPass = "http://unix:/run/rspamd/worker-controller.sock:/";
      recommendedProxySettings = true;
    };
    forceSSL = true;
    useACMEHost = "${config.networking.hostName}.${config.networking.domain}";
  };

  services.rspamd.workers.controller.includes = [
    (toString (pkgs.writeText "rspamd-worker-controller-password.inc" ''
      secure_ip = "192.168.100.0/24";
      secure_ip = "::0/0";
      #secure_ip = "0.0.0.0/0";
    ''))
  ];

  age.secrets."oauth2-proxy-secrets" = {
    file = ../../secrets/mail01/oauth2-proxy-secrets.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

  services.oauth2-proxy = {
    enable = true;
    provider = "oidc";
    scope = "openid email";

    clientID = "rspamd";

    oidcIssuerUrl = "https://idm.ffrn.de/oauth2/openid/${config.services.oauth2-proxy.clientID}";
    redirectURL = "https://${oauth2_proxy_domain}/oauth2/callback";

    keyFile = config.age.secrets."oauth2-proxy-secrets".path;
    nginx.domain = oauth2_proxy_domain;
    email.domains = [ "*" ];

    reverseProxy = true;

    cookie.domain = "ffrn.de";
    cookie.name = "_oauth2_proxy_${config.services.oauth2-proxy.clientID}";

    extraConfig = {
      whitelist-domain = ".ffrn.de";
      code-challenge-method = "S256";
      skip-provider-button = false;
      trusted-ip = "192.168.100.0/24";
    };
  };

  services.oauth2-proxy.nginx.virtualHosts."${rspamd_domain}".allowed_groups = [ "rspamd_users" ];

  services.nebula.networks."ffrn".firewall.inbound = lib.optionals (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) [
    {
      host = "any";
      port = 80;
      proto = "tcp";
      groups = [ "noc" ];
    }
    {
      host = "any";
      port = 443;
      proto = "tcp";
      groups = [ "noc" ];
    }
    {
      host = "any";
      port = 443;
      proto = "udp";
      groups = [ "noc" ];
    }
  ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 443 ];

}
