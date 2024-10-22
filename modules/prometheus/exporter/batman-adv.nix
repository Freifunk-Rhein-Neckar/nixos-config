{ config, pkgs, ... }:
{

  services.prometheus.exporters.node = {
    enabledCollectors = [
      "textfile"
    ];
    extraFlags = [
      "--collector.textfile.directory=/var/lib/prometheus-node-exporter"
    ];
  };

  systemd.services.prometheus-batadv-txtexport = {
    description = "Run prometheus exporter batadv-txtexport script";
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.busybox}/bin/mkdir -p /var/lib/prometheus-node-exporter";
      ExecStart = "${pkgs.writeScript "prometheus-batadv-txtexport" ''
        #!/bin/sh
        BATCTL=${pkgs.batctl}/bin/batctl

        for batdev in /sys/class/net/bat-dom*; do
          test -d $batdev || exit 0
          batdev=$(basename $batdev)
          ${pkgs.ethtool}/bin/ethtool  -S $batdev | ${pkgs.busybox}/bin/awk -v batdev=$batdev '
            /^     .*:/ {
              gsub(":", "");
              print "batman_" $1 "{batdev=\"" batdev "\"} " $2
            }
          '

          echo "batman_originator_count{batdev=\"$batdev\",selected=\"false\"}" $($BATCTL meshif $batdev o | ${pkgs.busybox}/bin/egrep '^   ' | ${pkgs.busybox}/bin/wc -l)
          echo "batman_originator_count{batdev=\"$batdev\",selected=\"true\"}" $($BATCTL meshif $batdev o | ${pkgs.busybox}/bin/egrep '^ \*' | ${pkgs.busybox}/bin/wc -l)
          echo "batman_tg_count{batdev=\"$batdev\",type=\"multicast\"}" $(($($BATCTL meshif $batdev tg -m | ${pkgs.busybox}/bin/wc -l) - 2))
          echo "batman_tg_count{batdev=\"$batdev\",type=\"unicast\"}" $(($($BATCTL meshif $batdev tg -u | ${pkgs.busybox}/bin/wc -l) - 2))
        done
      ''}";
      StandardOutput = "file:/var/lib/prometheus-node-exporter/batadv.prom";
    };
  };

  systemd.timers.prometheus-batadv-txtexport = {
    description = "Run prometheus exporter batadv-txtexport script periodically";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Minutely"; # Adjust as needed
      # Unit = "prometheus-batadv-txtexport.service";
    };
  };
}