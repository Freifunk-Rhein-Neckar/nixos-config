{ lib, pkgs, config, ... }:
{
  services.prometheus.exporters = {
    node = {
      enable = true;
      listenAddress = "[::]";
      openFirewall = true;
      firewallRules = ''
        ip6 saddr { 2a02:c207:3001:370::/64 } tcp dport ${toString config.services.prometheus.exporters.node.port} counter accept comment "prometheus-node-exporter: accept from stats.ffrn.de"
        ip saddr { 5.189.157.196/32 } tcp dport ${toString config.services.prometheus.exporters.node.port} counter accept comment "prometheus-node-exporter: accept from stats.ffrn.de"
        ${ if (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) then ''
          iifname "${config.services.nebula.networks."ffrn".tun.device}" tcp dport ${toString config.services.prometheus.exporters.node.port} counter accept comment "prometheus-node-exporter: accept from nebula"
        '' else ""}
      '';
      disabledCollectors = [
        "arp"
        "bcache"
        "bonding"
        "cpufreq"
        "edac"
        "filefd"
        "infiniband"
        "ipvs"
        "mdadm"
        "netstat"
        "nfs"
        "nfsd"
        "sockstat"
        "textfile"
        "timex"
        "vmstat"
        "xfs"
        "zfs"
      ];
      enabledCollectors = [
        "logind"
        "systemd"
      ];
    };
  };
}

