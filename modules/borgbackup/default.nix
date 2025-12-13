{ lib, config, name, ... }:

with lib;

let
  cfg = config.modules.ffrn.borgbackup;
in {
  options.modules.ffrn.borgbackup = {
    enable = mkEnableOption "Enable Borgbackup (enabled by default)";
  };

  config = mkIf cfg.enable {

    age.secrets."borgbackup-passphrase" = {
      file = ../../secrets/${name}/borgbackup-passphrase.age;
      mode = "0400";
      owner = "root";
      group = "root";
    };

    age.secrets."borgbackup-sshkey" = {
      file = ../../secrets/${name}/borgbackup-sshkey.age;
      mode = "0400";
      owner = "root";
      group = "root";
    };

    programs.ssh.knownHosts = {
      "ffrn.backup.haufe.it" = {
        hostNames = [ "ffrn.backup.haufe.it" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINZAUDW97OnitiGwLtUJPc5+Tt9tKOJEG6hBuKn34cDF";
      };
    };

    services.borgbackup.jobs = {
      rootBackup = {
        paths = "/";
        exclude = [
          "/bin"
          "/dev"
          "/etc"
          "/nix"
          "/proc"
          "/root/.config/borg"
          "/run"
          "/sys"
          "/tmp"
          "/var/cache"
          "/var/empty"
          "/var/tmp"
          "/usr"
        ];
        repo = "ffrn@ffrn.backup.haufe.it:/./borg/${config.networking.hostName}.${config.networking.domain}";
        environment = { BORG_RSH = "ssh -i ${config.age.secrets."borgbackup-sshkey".path}"; };
        encryption = {
          mode = "repokey-blake2";
          passCommand = "cat ${config.age.secrets."borgbackup-passphrase".path}";
        };
        compression = "auto,zstd";
        startAt = "daily";
        failOnWarnings = false;
      };
    };
  };
}
