{ config, pkgs, ... }:
{
  security.acme = {
    certs."${config.networking.hostName}.${config.networking.domain}" = {
      extraDomainNames = [
        "vectortiles.ffrn.de"
      ];
    };
  };

  services.nginx.proxyCachePath."vectortilecache" = {
    enable = true;
    levels = "1:2";
    inactive = "14d";
    keysZoneName = "vectortilecache";
    keysZoneSize = "64m";
    maxSize = "4096M";
  };

  services.nginx.virtualHosts."vectortiles.ffrn.de" = {
    locations."/tiles/" = {
      proxyPass = "http://[::1]:8080/tiles/";
      extraConfig = ''
        add_header X-Cache-Status $upstream_cache_status;
        add_header X-Cache-Upstream-Status $upstream_http_x_cache_status;
        proxy_cache vectortilecache;
        proxy_store off;
        proxy_cache_key $uri$is_args$args;
        # proxy_cache_key $uri;
        proxy_cache_valid 200 301 302 14d;
        proxy_cache_valid 404 1m;
        proxy_cache_valid any 1m;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504 http_403 http_404;
        proxy_cache_use_stale error timeout updating invalid_header http_500 http_502 http_503 http_504 http_403 http_404;
        proxy_hide_header Via;
        proxy_hide_header X-Cache;
        proxy_hide_header X-Cache-Lookup;
        proxy_hide_header X-Cache-Status;
        proxy_hide_header Strict-Transport-Security;
        proxy_hide_header Set-Cookie;
        proxy_ignore_headers Set-Cookie;
        proxy_ignore_headers X-Accel-Expires Expires Cache-Control;
        expires 14d;
      '';
    };
    locations."/assets/" = {
      alias = "/srv/versatiles/static/assets/";
      extraConfig = ''
        add_header access-control-allow-origin *;
      '';
    };
    locations."/" = {
      proxyPass = "http://[::1]:8080";
    };
    quic = true;
    extraConfig = ''
      add_header Alt-Svc 'h3=":$server_port"; ma=86400';
    '';
    forceSSL = true;
    useACMEHost = "${config.networking.hostName}.${config.networking.domain}";
  };

  services.nginx.package = pkgs.nginxQuic;
  networking.firewall.extraInputRules = ''
    udp dport 443 counter accept comment "nginx: accept quic"
  '';

  services.borgbackup.jobs.rootBackup.exclude = [
    "/srv/versatiles/data"
  ];
}