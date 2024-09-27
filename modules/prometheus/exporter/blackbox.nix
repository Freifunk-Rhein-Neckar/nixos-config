{ pkgs, config, lib, ... }:
{

  services.prometheus.exporters.blackbox = {
    enable = true;
    listenAddress = "[::]";
    openFirewall = true;
    firewallRules = ''
      # ip6 saddr { 2a02:c207:3001:370::/64, 2a03:4000:60:11f::/64 } tcp dport ${toString config.services.prometheus.exporters.blackbox.port} counter accept comment "prometheus-blackbox-exporter: accept from stats.ffrn.de"
      # ip saddr { 5.189.157.196/32, 89.58.15.197/32 } tcp dport ${toString config.services.prometheus.exporters.blackbox.port} counter accept comment "prometheus-blackbox-exporter: accept from stats.ffrn.de"
      ${ if (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) then ''
        iifname "${config.services.nebula.networks."ffrn".tun.device}" tcp dport ${toString config.services.prometheus.exporters.blackbox.port} counter accept comment "prometheus-blackbox-exporter: accept from nebula"
      '' else ""}
    '';
    configFile = pkgs.writeText "config.yml" (builtins.toJSON {
      modules.icmp = {
        prober = "icmp";
      };
      modules.icmp4 = {
        prober = "icmp";
        icmp.preferred_ip_protocol = "ip4";
        icmp.ip_protocol_fallback = false;
      };
      modules.icmp6 = {
        prober = "icmp";
        icmp.preferred_ip_protocol = "ip6";
        icmp.ip_protocol_fallback = false;
      };
      modules.http_2xx = {
        prober = "http";
      };
      modules.http_post_2xx = {
        prober = "http";
        http.method = "POST";
      };
      modules.tcp_connect = {
        prober = "tcp";
      };
      modules.tls_connect = {
        prober = "tcp";
        timeout = "5s";
        tcp.tls = true;
      };
      modules.imap_ip4_starttls = {
        prober = "tcp";
        timeout = "5s";
        tcp.preferred_ip_protocol = "ip4";
        tcp.ip_protocol_fallback = false;
        tcp.query_response = [
          { expect = "OK.*STARTTLS"; }
          { send = ". STARTTLS"; }
          { expect = "OK"; }
          { starttls = true; }
          { send = ". capability"; }
          { expect = "CAPABILITY IMAP4rev1"; }
        ];
      };
      modules.imap_ip6_starttls = {
        prober = "tcp";
        timeout = "5s";
        tcp.preferred_ip_protocol = "ip6";
        tcp.ip_protocol_fallback = false;
        tcp.query_response = [
          { expect = "OK.*STARTTLS"; }
          { send = ". STARTTLS"; }
          { expect = "OK"; }
          { starttls = true; }
          { send = ". capability"; }
          { expect = "CAPABILITY IMAP4rev1"; }
        ];
      };
      modules.smtp_ip4_starttls = {
        prober = "tcp";
        timeout = "5s";
        tcp.preferred_ip_protocol = "ip4";
        tcp.ip_protocol_fallback = false;
        tcp.query_response = [
          { expect = "^220 ([^ ]+) ESMTP (.+)$"; }
          { send = "EHLO prober\r"; }
          { expect = "^250-STARTTLS"; }
          { send = "STARTTLS\r"; }
          { expect = "^220"; }
          { starttls = true; }
          { send = "EHLO prober\r"; }
          { expect = "^250-AUTH"; }
          { send = "QUIT\r"; }
        ];
      };
      modules.smtp_ip6_starttls = {
        prober = "tcp";
        timeout = "5s";
        tcp.preferred_ip_protocol = "ip6";
        tcp.ip_protocol_fallback = false;
        tcp.query_response = [
          { expect = "^220 ([^ ]+) ESMTP (.+)$"; }
          { send = "EHLO prober\r"; }
          { expect = "^250-STARTTLS"; }
          { send = "STARTTLS\r"; }
          { expect = "^220"; }
          { starttls = true; }
          { send = "EHLO prober\r"; }
          { expect = "^250-AUTH"; }
          { send = "QUIT\r"; }
        ];
      };
      modules.pop3s_ip4_banner = {
        prober = "tcp";
        tcp.preferred_ip_protocol = "ip4";
        tcp.ip_protocol_fallback = false;
        tcp.query_response = [
          { expect = "^+OK"; }
        ];
        tcp.tls = true;
        tcp.tls_config = {
          insecure_skip_verify = false;
        };
      };
      modules.pop3s_ip6_banner = {
        prober = "tcp";
        tcp.preferred_ip_protocol = "ip6";
        tcp.ip_protocol_fallback = false;
        tcp.query_response = [
          { expect = "^+OK"; }
        ];
        tcp.tls = true;
        tcp.tls_config = {
          insecure_skip_verify = false;
        };
      };
      modules.ssh_banner = {
        prober = "tcp";
        tcp.query_response = [
          { expect = "^SSH-2.0-"; }
        ];
      };
      modules.dns_soa = {
        prober = "dns";
        dns.query_name = "ffrn.de";
        dns.query_type = "SOA";
      };
      modules.dns_udp = {
        prober = "dns";
        timeout = "5s";
        dns.query_name = "youtube.com";
        dns.query_type = "AAAA";
        dns.transport_protocol = "udp";
        dns.valid_rcodes = [ "NOERROR" ];
      };
      modules.dns_tcp = {
        prober = "dns";
        timeout = "5s";
        dns.query_name = "youtube.com";
        dns.query_type = "AAAA";
        dns.transport_protocol = "tcp";
        dns.valid_rcodes = [ "NOERROR" ];
      };
    });
  };
}