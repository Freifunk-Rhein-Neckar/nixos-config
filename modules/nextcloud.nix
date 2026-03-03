{ config, lib, pkgs, ... }:
let
  domain = "cloud.ffrn.de";
  acmeDomain = "${config.networking.hostName}.${config.networking.domain}";

  cfg = config.services.nextcloud;
  fpm = config.services.phpfpm.pools.nextcloud;
  webserver = config.services.nginx;
in {
  imports = [
    ./acme.nix
    ./nginx.nix
    ./postgresql
  ];

  security.acme.certs."${acmeDomain}" = {
    extraDomainNames = [
      "${domain}"
    ];
  };

  services.postgresql = {
    ensureDatabases = [ config.services.nextcloud.config.dbname ];
    ensureUsers = [ {
      name = config.services.nextcloud.config.dbuser;
      ensureDBOwnership = true;
    } ];
  };

  services.postgresqlBackup.databases = [ config.services.nextcloud.config.dbname ];

  systemd.services.nextcloud-setup = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

  age.secrets."nextcloud-adminpass" = {
    file = ../secrets/cloud1/nextcloud-adminpass.age;
  };

  age.secrets."nextcloud-s3-key-secret" = {
    file = ../secrets/cloud1/nextcloud-s3-key-secret.age;
  };
  # age.secrets."nextcloud-s3-sseCKey" = {
  #   file = ../secrets/cloud1/nextcloud-s3-sseCKey.age;
  # };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud33;
    hostName = domain;
    https = true;
    home = "/srv/nextcloud";
    caching = {
      #apcu = false;
    };
    configureRedis = true;
    phpOptions = {
      "opcache.interned_strings_buffer" = "24";
    };
    config = {
      adminpassFile = config.age.secrets."nextcloud-adminpass".path;
      dbhost = "/run/postgresql";
      dbtype = "pgsql";
      dbuser = "nextcloud";

      objectstore.s3 = {
        enable = true;
        bucket = "nextcloud";
        key = "GK30d4a6d55fb540ed8b9d069d";
        secretFile = config.age.secrets."nextcloud-s3-key-secret".path;
        # sseCKeyFile = config.age.secrets."nextcloud-s3-sseCKey".path;
        usePathStyle = true;
        verify_bucket_exists = false;
        hostname = "127.0.0.1";
        port = 3900;
        region = "garage";
        useSsl = false;
      };

    };
    settings = {
      default_phone_region = "DE";
      trusted_proxies = [ "127.0.0.1" "::1" ];
      maintenance_window_start = 1;
      versions_retention_obligation = "14, auto";

      allow_user_to_change_display_name = false;
      allow_user_to_change_email = false;
      lost_password_link = "disabled";

      allow_local_remote_servers = true;
    };
    poolSettings = {
      "pm" = "dynamic";
      "pm.max_children" = "120";
      "pm.max_requests" = "500";
      "pm.max_spare_servers" = "18";
      "pm.min_spare_servers" = "6";
      "pm.start_servers" = "12";
    };
  };

  systemd.services.nextcloud-setup.serviceConfig.ExecStartPost = pkgs.writeScript "nextcloud-runtime-settings.sh" ''
    #!${pkgs.runtimeShell}
    
    nextcloud-occ app:disable logreader
    nextcloud-occ app:disable dashboard
    nextcloud-occ app:disable firstrunwizard
    nextcloud-occ app:install user_oidc
    nextcloud-occ app:install groupfolders

    #nextcloud-occ config:app:set --value=0 user_oidc allow_multiple_user_backends

    #nextcloud-occ config:system:set redis 'host' --value '::1' --type string
    #nextcloud-occ config:system:set redis 'port' --value 6379 --type integer
    nextcloud-occ config:system:set memcache.local --value '\OC\Memcache\Redis' --type string
    #nextcloud-occ config:system:set memcache.local --value '\OC\Memcache\APCu' --type string
    #nextcloud-occ config:system:set memcache.locking --value '\OC\Memcache\Redis' --type string
    #nextcloud-occ config:system:set memcache.distributed --value '\OC\Memcache\Redis' --type string

    nextcloud-occ config:system:set --value smtp mail_smtpmode
    nextcloud-occ config:system:set --value mail.ffrn.de mail_smtphost
    nextcloud-occ config:system:set --value 465 --type int mail_smtpport
    nextcloud-occ config:system:set --value ssl mail_smtpsecure
    nextcloud-occ config:system:set --value "tools@ffrn.de" mail_smtpname
  '';

  services.phpfpm.pools.nextcloud.settings = {
    "listen.owner" = webserver.user;
    "listen.group" = webserver.group;
  };

  services.nginx = {
    virtualHosts."${domain}" = {
      forceSSL = true;
      useACMEHost = acmeDomain;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443];
  networking.firewall.allowedUDPPorts = [ 443];
}
