{ config, lib, pkgs, ... }:

let
  isGarageHost = lib.hasPrefix "garage" config.networking.hostName;
  data_dir = if isGarageHost then "/garage/data" else "/var/lib/garage/data";
  metadata_dir = "/var/lib/garage/meta";
in
{
  fileSystems = lib.mkIf isGarageHost {
    "${data_dir}" = {
      device = "/dev/disk/by-label/garage-data";
      fsType = "xfs";
    };
  };

  users.users.garage = {
    isSystemUser = true;
    group = "garage";
  };
  users.groups.garage = { };

  systemd.services.garage.serviceConfig = {
    User = "garage";
    Group = "garage";
    ReadWriteDirectories = lib.mkIf isGarageHost[
      data_dir
    ];
    DynamicUser = false;
    StateDirectory = "garage";
  };

  age.secrets."garage-rpc-secret" = {
    file = ../secrets/garage/rpc-secret.age;
    mode = "0400";
    owner = "garage";
    group = "garage";
  };

  services.garage = {
    enable = true;
    package = pkgs.garage_2;
    extraEnvironment = {
      GARAGE_RPC_SECRET_FILE = config.age.secrets."garage-rpc-secret".path;
    };
    settings = {
      # https://garagehq.deuxfleurs.fr/documentation/reference-manual/configuration/
      inherit data_dir metadata_dir;

      db_engine = "lmdb";

      replication_factor = 3;
      compression_level = 7;
      # consistency_mode = "degraded";

      rpc_bind_addr = "[::]:3901";
      rpc_public_addr_subnet = "192.168.100.0/24";

      s3_api = {
        s3_region = "garage";
        api_bind_addr = "127.0.0.1:3900";
        root_domain = ".s3.ffrn.de";
      };

      s3_web = {
        bind_addr = "127.0.0.1:3902";
        root_domain = ".web.ffrn.de";
        index = "index.html";
      };

      admin.api_bind_addr = "0.0.0.0:3903";
    };
  };

  environment.systemPackages = [ pkgs.minio-client ];

  services.nebula.networks."ffrn".firewall.inbound = lib.optionals (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) [
    {
      host = "any";
      port = 3901;
      proto = "tcp";
      groups = [ "garage" ];
    }
    {
      host = "any";
      port = 3903;
      proto = "tcp";
      groups = [ "garage" "noc" "prometheus" ];
    }
  ];

  networking.firewall.extraInputRules = ''
    ${ if (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) then ''
      iifname "${config.services.nebula.networks."ffrn".tun.device}" tcp dport 3901 counter accept comment "garage: accept rpc from nebula"
      iifname "${config.services.nebula.networks."ffrn".tun.device}" tcp dport 3903 counter accept comment "garage: accept admin from nebula"
    '' else ""}
  '';

  # services.borgbackup.jobs.rootBackup.exclude = [
  #   "/garage/"
  # ];
}
