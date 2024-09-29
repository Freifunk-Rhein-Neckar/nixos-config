{ lib, config, name, ... }:

{

  age.secrets."acme" = {
    file = ../secrets/${name}/acme.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

  security.acme = {
    defaults = {
      email = "certificates@ffrn.de";
      dnsProvider = "rfc2136";
      credentialsFile = config.age.secrets."acme".path;
    };
    acceptTerms = true;
  };

  users.groups."${config.security.acme.certs."${config.networking.hostName}.${config.networking.domain}".group}".members = if config.services.nginx.enable then [ "${config.services.nginx.user}" ] else [];

}