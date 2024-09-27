{ config, pkgs, lib, ... }:
{

  imports = [
    ./exporter/blackbox.nix
    ./rules.nix
  ];

  services.prometheus = {
    enable = true;
    listenAddress = "[::]";
    webExternalUrl = "http://prometheus.int.ffrn.de/";
    globalConfig = {
      scrape_interval = "15s";
      evaluation_interval = "15s";
    };
    retentionTime = "365d";
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "node";
      static_configs = [{
        targets = [
          "gw02.int.ffrn.de:9100"
          "gw03.int.ffrn.de:9100"
          "gw04.int.ffrn.de:9100"
          "gw05.int.ffrn.de:9100"
          "gw06.int.ffrn.de:9100"
          "gw07.int.ffrn.de:9100"
          "gw08.int.ffrn.de:9100"
          "gw09.int.ffrn.de:9100"
          "map2.int.ffrn.de:9100"
          "stats.int.ffrn.de:9100"

          # "forum1.in.ffrn.de:9100"
          # "tools-elsenz.in.ffrn.de:9100"
          # "tools-itter.in.ffrn.de:9100"
          # "unifi.in.ffrn.de:9100"
          # "tickets.in.ffrn.de:9100"
          # "resolver1.in.ffrn.de:9100"
          # "resolver2.in.ffrn.de:9100"
          # "map1.in.ffrn.de:9100"
          # "meet.in.ffrn.de:9100"
          # "stats.in.ffrn.de:9100"
          # "elsenz.in.ffrn.de:9100"
          # "itter.in.ffrn.de:9100"
          # "master.in.ffrn.de:9100"
          # "weschnitz.in.ffrn.de:9100"
        ];
      }];
    }

    {
      job_name = "icmp4";
      metrics_path = "/probe";
      params.module = [ "icmp4" ];
      static_configs = [{ targets = [
          "gw02.int.ffrn.de"
          "gw03.int.ffrn.de"
          "gw04.int.ffrn.de"
          "gw05.int.ffrn.de"
          "gw06.int.ffrn.de"
          "gw07.int.ffrn.de"
          "gw08.int.ffrn.de"
          "gw09.int.ffrn.de"
          "map2.int.ffrn.de"
          "stats.int.ffrn.de"

          "gw02.ffrn.de"
          "gw03.ffrn.de"
          "gw04.ffrn.de"
          "gw05.ffrn.de"
          "gw06.ffrn.de"
          "gw07.ffrn.de"
          "gw08.ffrn.de"
          "gw09.ffrn.de"
          "map.ffrn.de"
          "stats.ffrn.de"

          "8.8.8.8"
          "8.8.4.4"
          "1.1.1.1"
          "1.0.0.1"

          "forum.ffrn.de"
          "tools-elsenz.ffrn.de"
          "tools-itter.ffrn.de"
          "tickets.ffrn.de"
          "map1.ffrn.de"
          "meet.ffrn.de"

          "elsenz.ffrn.de"
          "itter.ffrn.de"
          "weschnitz.ffrn.de"

          "master.ffrn.de"

          "uplink.ebert-park-hotel.weinheim.ffrn.de"

        ];
      }];
      relabel_configs = [{
        source_labels = [ "__address__" ];
        target_label = "__param_target";
      } {
        source_labels = [ "__param_target" ];
        target_label = "instance";
      }{
        target_label = "__address__";
        replacement = "stats.int.ffrn.de:9115";
      }];
    }
    {
      job_name = "icmp4_extra";
      metrics_path = "/probe";
      params.module = [ "icmp4" ];
      static_configs = [{ targets = [
          "core1.man.da.as6766.net"
          "grumpy.darmstadt.freifunk.net"
          "sneezy.darmstadt.freifunk.net"
          "sleepy.darmstadt.freifunk.net"
          "happy.darmstadt.freifunk.net"
        ];
      }];
      relabel_configs = [{
        source_labels = [ "__address__" ];
        target_label = "__param_target";
      } {
        source_labels = [ "__param_target" ];
        target_label = "instance";
      }{
        target_label = "__address__";
        replacement = "stats.int.ffrn.de:9115";
      }];
    }
    {
      job_name = "icmp6";
      metrics_path = "/probe";
      params.module = [ "icmp6" ];
      static_configs = [{ targets = [
          "gw02.ffrn.de"
          "gw03.ffrn.de"
          "gw04.ffrn.de"
          "gw05.ffrn.de"
          "gw06.ffrn.de"
          "gw07.ffrn.de"
          "gw08.ffrn.de"
          "gw09.ffrn.de"
          "map.ffrn.de"
          "stats.ffrn.de"

          "forum.ffrn.de"
          "tools-elsenz.ffrn.de"
          "tools-itter.ffrn.de"
          "unifi.ffrn.de"
          "tickets.ffrn.de"
          "resolver1.ffrn.de"
          "resolver2.ffrn.de"
          "map1.ffrn.de"
          "meet.ffrn.de"

          "elsenz.ffrn.de"
          "itter.ffrn.de"
          "weschnitz.ffrn.de"

          "master.ffrn.de"

          "2001:4860:4860::8888"
          "2001:4860:4860::8844"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];
      }];
      relabel_configs = [{
        source_labels = [ "__address__" ];
        target_label = "__param_target";
      } {
        source_labels = [ "__param_target" ];
        target_label = "instance";
      }{
        target_label = "__address__";
        replacement = "stats.int.ffrn.de:9115";
      }];
    }
    {
      job_name = "icmp6_extra";
      metrics_path = "/probe";
      params.module = [ "icmp6" ];
      static_configs = [{ targets = [
          "core1.man.da.as6766.net"
          "grumpy.darmstadt.freifunk.net"
          "sneezy.darmstadt.freifunk.net"
          "sleepy.darmstadt.freifunk.net"
          "happy.darmstadt.freifunk.net"
        ];
      }];
      relabel_configs = [{
        source_labels = [ "__address__" ];
        target_label = "__param_target";
      } {
        source_labels = [ "__param_target" ];
        target_label = "instance";
      }{
        target_label = "__address__";
        replacement = "stats.int.ffrn.de:9115";
      }];
    }

    {
      job_name = "blackbox_http";
      scrape_interval = "5m";
      metrics_path = "/probe";
      params.module = [ "http_2xx" ];
      static_configs = [{ targets = [
          "ffrn.de"
          "freifunk-rhein-neckar.de"
          "forum.ffrn.de"
          "map.ffrn.de"
          "tiles.ffrn.de"
          "meet.ffrn.de"
          "stats.ffrn.de"
          "cloud.ffrn.de"
          "matrix.ffrn.de"
          "pads.ffrn.de"
          "register.ffrn.de"
          "element.ffrn.de"
          "blog.ffrn.de"
          "ffapi.ffrn.de"
          "wiki.ffrn.de"
          "tickets.ffrn.de"
          "unifi.ffrn.de"
          "mail.ffrn.de"
        ];
      }];
      relabel_configs = [{
        source_labels = [ "__address__" ];
        target_label = "__param_target";
      } {
        source_labels = [ "__param_target" ];
        target_label = "instance";
      }{
        target_label = "__address__";
        replacement = "stats.int.ffrn.de:9115";
      }];
    }
    {
      job_name = "kea";
      static_configs = [{
        targets = [
          "gw02.int.ffrn.de:9547"
          "gw03.int.ffrn.de:9547"
          "gw04.int.ffrn.de:9547"
          "gw05.int.ffrn.de:9547"
          "gw06.int.ffrn.de:9547"
          "gw07.int.ffrn.de:9547"
          "gw08.int.ffrn.de:9547"
          "gw09.int.ffrn.de:9547"
        ];
      }];
    }
    {
      job_name = "fastd";
      static_configs = [{
        targets = [
          "gw02.int.ffrn.de:9281"
          "gw03.int.ffrn.de:9281"
          "gw04.int.ffrn.de:9281"
          "gw05.int.ffrn.de:9281"
          "gw06.int.ffrn.de:9281"
          "gw07.int.ffrn.de:9281"
          "gw08.int.ffrn.de:9281"
          "gw09.int.ffrn.de:9281"
        ];
      }];
    }
    {
      job_name = "blackbox";
      static_configs = [{
        targets = [
          "stats.int.ffrn.de:9115"
        ];
      }];
    }
    {
      job_name = "dns_soa";
      metrics_path = "/probe";
      params.module = [ "dns_soa" ];
      static_configs = [{ targets = [
          "ns1.ffrn.de"
          "ns2.ffrn.de"
          "ns3.ffrn.de"
        ];
      }];
      relabel_configs = [{
        source_labels = [ "__address__" ];
        target_label = "__param_target";
      } {
        source_labels = [ "__param_target" ];
        target_label = "instance";
      }{
        target_label = "__address__";
        replacement = "stats.int.ffrn.de:9115";
      }];
    }


  ];

  services.nebula.networks."ffrn".firewall.inbound = if (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) then [
    {
      host = "any";
      port = config.services.prometheus.port;
      proto = "tcp";
      groups = [ "noc" "prometheus" ];
    }
  ] else [];

  networking.firewall.extraInputRules = ''
    ${ if (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) then ''
      iifname "${config.services.nebula.networks."ffrn".tun.device}" tcp dport ${toString config.services.prometheus.port} counter accept comment "prometheus: accept from nebula"
    '' else ""}
  '';
}