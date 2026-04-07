{ config, lib, pkgs, name, ... }:
let
  sources = import ../../npins;
in
{
  imports = [
    (import sources.nixos-mailserver)
    ../../modules/acme.nix
    ../../secrets/${name}/accounts.nix
    ../../secrets/${name}/rspamd.nix
    ./rspamd-proxy.nix
  ];

  security.acme = {
    certs."${config.networking.hostName}.${config.networking.domain}" = {
      extraDomainNames = [
        "mail01.int.ffrn.de"
        "mail.ffrn.de"
      ];
      profile = "classic";
      validMinDays = 30;
      renewInterval = "daily";
      postRun = ''
        systemctl try-reload-or-restart postfix.service dovecot2.service
      '';
    };
  };

  fileSystems = {
    "/var/vmail" = {
      device = "rpool/mail/vmail";
      fsType = "zfs";
    };
    "/var/dkim" = {
      device = "rpool/mail/dkim";
      fsType = "zfs";
    };
    "/var/sieve" = {
      device = "rpool/mail/sieve";
      fsType = "zfs";
    };
  };

  mailserver = {
    enable = true;
    stateVersion = 3;
    fqdn = "mail.ffrn.de";
    sendingFqdn = "mail01.ffrn.de";
    domains = [
      "ffrn.de"
      "freifunk-rhein-neckar.de"
      "rhein-neckar.freifunk.net"
      "ffrn.net"
      "ffbw.de"
      "ffwhm.de"
      "freifunk-bw.de"
      "freifunk-heidelberg.de"
      "freifunk-ludwigshafen.de"
      "freifunk-mannheim.de"
      "freifunk-odenwald.de"
      "freifunk-weinheim.de"
    ];

    certificateScheme = "manual";

    certificateFile = config.security.acme.certs."${config.networking.hostName}.${config.networking.domain}".directory + "/cert.pem";
    keyFile = config.security.acme.certs."${config.networking.hostName}.${config.networking.domain}".directory + "/key.pem";

    # Enable IMAP, SMTP and POP3 over SSL/TLS
    enableImapSsl = true;
    enablePop3Ssl = true; # forum reply mails
    enableSubmissionSsl = true;

    # Enable the ManageSieve protocol
    enableManageSieve = true;

    hierarchySeparator = "/";
  };
}