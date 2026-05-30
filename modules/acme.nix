{ lib, config, name, ... }:

{

  age.secrets."acmeEnv" = {
    file = ../secrets/${name}/acmeEnv.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

  age.secrets."acmeTSIG" = {
    file = ../secrets/${name}/acmeTSIG.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

  security.acme = {
    defaults = {
      dnsProvider = "rfc2136";
      credentialFiles = {
        "RFC2136_TSIG_SECRET_FILE" = config.age.secrets."acmeTSIG".path;
      };
      environmentFile = config.age.secrets."acmeEnv".path;

      # default to shortlived profile
      profile = lib.mkDefault "shortlived";
      validMinDays = lib.mkDefault 3;
      renewInterval = lib.mkDefault "3/6:00:00";
    };
    acceptTerms = true;
  };

  users.groups."${config.security.acme.certs."${config.networking.hostName}.${config.networking.domain}".group}".members = if config.services.nginx.enable then [ "${config.services.nginx.user}" ] else [];

}
