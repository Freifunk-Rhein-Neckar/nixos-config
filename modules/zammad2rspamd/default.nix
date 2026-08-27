{ config, lib, pkgs, ... }:
let
  cfg = config.services.zammad2rspamd;
  pkg = pkgs.callPackage ./pkg.nix {};
in {
  options.services.zammad2rspamd = {
    enable = lib.mkEnableOption "Zammad to Rspamd spam sync service";

    interval = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      description = "Systemd calendar event expression for running the sync.";
    };

    zammadUrl = lib.mkOption {
      type = lib.types.str;
      example = "https://zammad.example.com";
      description = "Full URL to Zammad instance.";
    };

    rspamdUrl = lib.mkOption {
      type = lib.types.str;
      example = "https://rspamd.example.com";
      description = "Full URL to Rspamd Web UI.";
    };

    lastUpdatedHours = lib.mkOption {
      type = lib.types.int;
      default = 6;
      description = "Lookback window in hours for updated tickets.";
    };

    zammadTokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      example = "/var/lib/secrets/zammad_token";
      description = "Path to file containing Zammad API token.";
    };

    rspamdPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/var/lib/secrets/rspamd_password";
      description = "Path to file containing Rspamd password.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.zammad2rspamd = {
      description = "Zammad to Rspamd spam and ham learning task";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        Restart = "no";
        ExecStart = "${pkg}/bin/zammad2rspamd --daemon";

        LoadCredential =
          (lib.optional (cfg.zammadTokenFile != null) "zammad_token:${cfg.zammadTokenFile}") ++
          (lib.optional (cfg.rspamdPasswordFile != null) "rspamd_password:${cfg.rspamdPasswordFile}");

        DynamicUser = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
      };

      environment = {
        ZAMMAD_URL = cfg.zammadUrl;
        RSPAMD_URL = cfg.rspamdUrl;
        LAST_UPDATED = toString cfg.lastUpdatedHours;
      };
    };

    systemd.timers.zammad2rspamd = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.interval;
        RandomizedDelaySec = "5m";
      };
    };
  };
}
