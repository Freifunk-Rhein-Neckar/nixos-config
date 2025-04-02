{ config, pkgs, ... }:
let
  domain = "attic.ffrn.de";
in
{
  imports = [
    ../../modules/attic.nix
  ];
  security.acme = {
    certs."${config.networking.hostName}.${config.networking.domain}" = {
      extraDomainNames = [
        "${domain}"
      ];
    };
  };

  services.nginx.virtualHosts."${domain}" = {
    locations."/" = {
      proxyPass = "http://${config.services.atticd.settings.listen}";
      extraConfig = ''
        client_max_body_size 5120M;
      '';
    };
    # quic = true;
    # extraConfig = ''
    #   add_header Alt-Svc 'h3=":$server_port"; ma=86400';
    # '';
    forceSSL = true;
    useACMEHost = "${config.networking.hostName}.${config.networking.domain}";
  };

  services.borgbackup.jobs.rootBackup.exclude = [
    "/var/lib/private/atticd/storage"
    # "/var/lib/atticd"
  ];
}