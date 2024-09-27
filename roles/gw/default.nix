{ name, nodes, config, pkgs, lib, ... }:
{

  imports = [
    (import (import ../../nix/sources.nix).nixos-freifunk)
    ../../modules/ffrn-gateway.nix
  ];

  age.secrets."fastd-secret.conf" = {
    file = ../../secrets/${name}/fastd.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

  age.secrets."id_ed25519_fastdkeys" = {
    file = ../../secrets/gw/id_ed25519_fastdkeys.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

  environment.systemPackages = with pkgs; [
    bridge-utils
    git
    fastd
    jq
    batctl
    tcpdump
  ];

  networking.firewall.allowedTCPPorts = [ 80 ];
  services.nginx.enable = true;
  services.nginx.virtualHosts."default" = {
    default = true;
    rejectSSL = true;
    locations."/" = {
      return = "200 \"<!DOCTYPE html><html><head></head><body><h1>${config.networking.fqdnOrHostName}</h1></body></html>\"";
      extraConfig = "default_type text/html;";
    };
  };

  modules.ffrn-gateway = {
    enable = lib.mkDefault true;
  };

  modules.freifunk.gateway = {
    enable = true;
    meta.contact = "info@ffrn.de";
    yanic.enable = true;
    blockTCPPort25 = true;
    fastd = {
      peerDir = "/var/lib/fastd/peer_groups/nodes";
      secretKeyIncludeFile = config.age.secrets."fastd-secret.conf".path;
      peerLimit = 100;
    };
    dnsDomainName = "ffrn.de";
    dnsSearchDomain = [
      "ffrn.de"
      "freifunk-rhein-neckar.de"
    ];
    domains = {
      dom0 = {
        names = {
          dom0 = "Domain 0";
          ffrn_default = "Default";
          ffrn = "Default";
        };
        vxlan.vni = 4011;
        ipv4 = {
          prefixes."10.142.0.0/16" = {};
          dhcpV4 = {
            enable = lib.mkDefault true;
            dnsServers = [ "10.95.255.53" "10.95.255.54" ];
          };
        };
        ipv6 = {
          dnsServers = [ "fdc3:67ce:cc7e:53::a" "fdc3:67ce:cc7e:53::b" ];
          prefixes = {
            "2a01:4f8:171:fcff::/64" = {
              announce = lib.mkDefault false;
            };
            "2a01:4f8:140:7700::/64" = {
              announce = lib.mkDefault false;
            };
            "2a01:4f8:160:9700::/64" = {
              announce = lib.mkDefault false;
            };
            "fdc3:67ce:cc7e:9001::/64" = {
            };
          };
        };
      };
    };
  };

  services.prometheus.exporters.kea = {
    openFirewall = true;
    firewallRules = ''
      ip6 saddr { 2a02:c207:3001:370::/64, 2a03:4000:60:11f::/64 } tcp dport ${toString config.services.prometheus.exporters.kea.port} counter accept comment "prometheus-kea-exporter: accept from stats.ffrn.de"
      ip saddr { 5.189.157.196/32, 89.58.15.197/32 } tcp dport ${toString config.services.prometheus.exporters.kea.port} counter accept comment "prometheus-kea-exporter: accept from stats.ffrn.de"
      ${ if (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) then ''
        iifname "${config.services.nebula.networks."ffrn".tun.device}" tcp dport ${toString config.services.prometheus.exporters.kea.port} counter accept comment "prometheus-kea-exporter: accept from nebula"
      '' else ""}
    '';
  };


  networking.nftables.tables.nixos-fw = {
    content = ''
      chain input_extra {
        tcp dport ${toString config.services.fastd-exporter.port} ip saddr { 5.189.157.196/32, 89.58.15.197/32 } counter accept comment "fastd-exporter: accept from stats.ffrn.de"
        tcp dport ${toString config.services.fastd-exporter.port} ip6 saddr { 2a02:c207:3001:370::/64, 2a03:4000:60:11f::/64 } counter accept comment "fastd-exporter: accept from stats.ffrn.de"
        ${ if (lib.hasAttr "ffrn" config.services.nebula.networks && config.services.nebula.networks.ffrn.enable) then ''
          iifname "${config.services.nebula.networks."ffrn".tun.device}" tcp dport ${toString config.services.fastd-exporter.port} counter accept comment "fastd-exporter: accept from nebula"
        '' else ""}
      }
    '';
  };

  networking.nftables.tables.postrouting = {
    content = ''
      chain postrouting_extra {}

      chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;

        jump postrouting_extra

        # ip saddr 10.0.0.0/8 counter masquerade
        # ip6 saddr fdeb:52c8:d094:1000::/64 counter masquerade
      }
    '';
    family = "inet";
  };

  services.freifunk.bird = {
    extraConfig = ''
      protocol direct d_domains {
        interface "bat-dom*";
        ipv4 {
            import all;
        };
        ipv6 {
            import all;
        };
      }
    '';
  };


  systemd.network.networks."10-mainif".networkConfig.VXLAN = config.modules.freifunk.gateway.vxlan.interfaceNames;

  programs.ssh.knownHosts."github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

  services.fastd-peergroup-nodes = {
    enable = true;
    reloadServices = map (service: "${service.unitName}.service") (builtins.attrValues config.services.fastd);
    repoUrl = "git@github.com:Freifunk-Rhein-Neckar/fastd-keys.git";
    repoBranch = "master";
    sshCommand = "${pkgs.openssh}/bin/ssh -i ${config.age.secrets."id_ed25519_fastdkeys".path}";
  };
}
