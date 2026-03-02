{ config, pkgs, ... }:
{
  imports = [
    # include when upgrading between versions
    #./upgrade.nix
  ];
  services.postgresql = {
    enable = true;
    # enable ./upgrade.nix and use `upgrade-pg-cluster` before changing the package version
    package = pkgs.postgresql_18;
  };
  services.prometheus.exporters.postgres = {
    enable = true;
    runAsLocalSuperUser = true;
  };

  services.postgresqlBackup = {
    enable = true;
    databases = [];
    startAt = [];
  };
#   services.borgbackup.jobs.rootBackup = {
#     exclude = [ "/var/lib/postgresql" ];
#   };
#   systemd.services.borgbackup-job-rootBackup = {
#     wants = (map (db: "postgresqlBackup-" + db + ".service") config.services.postgresqlBackup.databases);
#     after = (map (db: "postgresqlBackup-" + db + ".service") config.services.postgresqlBackup.databases);
#   };
}
