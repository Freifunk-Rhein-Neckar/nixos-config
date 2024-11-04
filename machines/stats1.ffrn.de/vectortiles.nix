{ config, pkgs, ... }:
{
  security.acme = {
    certs."${config.networking.hostName}.${config.networking.domain}" = {
      extraDomainNames = [
        "vectortiles.ffrn.de"
      ];
    };
  };

  services.nginx.virtualHosts."vectortiles.ffrn.de" = {
    locations."/" = {
      proxyPass = "http://[::1]:8080";
    };
    forceSSL = true;
    useACMEHost = "${config.networking.hostName}.${config.networking.domain}";
  };

  services.borgbackup.jobs.rootBackup.exclude = [
    "/srv/versatiles/data"
  ];
}