{ lib, config, pkgs, ... }:
{
  services.freifunk.bird = {

    extraTables = ''
      roa4 table dn42_roa_v4;
      roa6 table dn42_roa_v6;
    '';

    extraConfig = ''
      protocol static dn42_roa4 {
        roa4 { table dn42_roa_v4; };
        include "dn42_roa_bird2_4.conf";
      };

      protocol static dn42_roa6 {
        roa6 { table dn42_roa_v6; };
        include "dn42_roa_bird2_6.conf";
      };
    '';
  };

  services.bird2.preCheckConfig = ''
    echo "" > dn42_roa_bird2_4.conf;
    echo "" > dn42_roa_bird2_6.conf;
  '';

  systemd.services.dn42-roa = {
    description = "Update DN42 ROA";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${pkgs.curl}/bin/curl -sfSLR -o /etc/bird/dn42_roa_bird2_4.conf -z /etc/bird/dn42_roa_bird2_4.conf https://dn42.burble.com/roa/dn42_roa_bird2_4.conf"
        "${pkgs.curl}/bin/curl -sfSLR -o /etc/bird/dn42_roa_bird2_6.conf -z /etc/bird/dn42_roa_bird2_6.conf https://dn42.burble.com/roa/dn42_roa_bird2_6.conf"
      ];
      ExecStartPost = "${pkgs.systemd}/bin/systemctl reload bird2.service";
    };
  };

  systemd.timers.dn42-roa = {
    description = "Update DN42 ROA periodically";
    timerConfig = {
      OnBootSec = "2m";
      OnUnitActiveSec = "15m";
      AccuracySec = "1m";
    };
    wantedBy = [ "timers.target" ];
  };

}