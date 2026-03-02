{ config, lib, pkgs, ... }:
{

  imports = [
    ./acme.nix
  ];

  age.secrets."acme-garage" = {
    file = ../secrets/garage/acme.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

  security.acme = {
    certs."${config.networking.hostName}.${config.networking.domain}" = {
      extraDomainNames = [ ];
    };
  };

  security.acme.certs."garage.ffrn.de" = {
    extraDomainNames = [
      "web.ffrn.de"
      "*.web.ffrn.de"
      "s3.ffrn.de"
      "*.s3.ffrn.de"
    ];
    dnsProvider = "rfc2136";
    credentialsFile = config.age.secrets."acme-garage".path;
    # default to shortlived profile
    profile = "shortlived";
    validMinDays = 3;
    renewInterval = "3/6:00:00";
  };

  users.groups."${config.security.acme.certs."garage.ffrn.de".group}".members = if config.services.nginx.enable then [ "${config.services.nginx.user}" ] else [];

  services.caddy = {
    enable = true;
    virtualHosts."garage.ffrn.de" = {
      extraConfig = ''
        @not_localhost not remote_ip 127.0.0.1/8 ::1
        @not_prometheus not remote_ip 127.0.0.1/8 ::1 192.168.100.0/24

        handle /metrics {
          respond @not_prometheus "Forbidden" 403
        }
        handle {
          respond @not_localhost "Forbidden" 403
        }

        reverse_proxy ${config.services.garage.settings.admin.api_bind_addr} {
          health_uri       /health
          health_port      3903
          health_interval 15s
        }

      '';
      useACMEHost = "garage.ffrn.de";
    };
    virtualHosts."s3.ffrn.de" = {
      serverAliases = [ "*.s3.ffrn.de" ];
      extraConfig = ''
        reverse_proxy ${config.services.garage.settings.s3_api.api_bind_addr} {
          health_uri       /health
          health_port      3903
          health_interval 15s
        }
      '';
      useACMEHost = "garage.ffrn.de";
    };
    virtualHosts."web.ffrn.de" = {
      serverAliases = [ "*.web.ffrn.de" ];
      extraConfig = ''
        reverse_proxy ${config.services.garage.settings.s3_web.bind_addr} {
          health_uri       /health
          health_port      3903
          health_interval 15s
        }
      '';
      useACMEHost = "garage.ffrn.de";
    };
    # virtualHosts."https://" = {
    #   extraConfig = ''
    #     tls {
    #       on_demand
    #     }
    #     reverse_proxy ${config.services.garage.settings.s3_web.bind_addr} {
    #       health_uri       /health
    #       health_port      3903
    #       health_interval 15s
    #     }
    #   '';
    # };
    globalConfig = ''
      on_demand_tls {
        ask http://${config.services.garage.settings.admin.api_bind_addr}/check
        # interval 2m
        # burst 5
      }
      cert_issuer acme {
        dir https://acme-v02.api.letsencrypt.org/directory
        profile shortlived
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [ 80 443];
  networking.firewall.allowedUDPPorts = [ 443];
}