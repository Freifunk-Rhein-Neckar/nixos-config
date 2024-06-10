{ name, nodes, config, pkgs, lib, ... }:
{

  imports = [
    ../../modules/freifunk
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

  modules.freifunk.gateway = {
    enable = true;
    yanic.enable = true;
    fastd = {
      peerDir = "/var/lib/fastd/peer_groups/nodes";
      secretKeyIncludeFile = config.age.secrets."fastd-secret.conf".path;
      peerLimit = 100;
    };
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
      };
    };
  };

  services.prometheus.exporters.kea = {
    openFirewall = true;
    firewallRules = ''
      ip6 saddr { 2a02:c207:3001:370::/64 } tcp dport ${toString config.services.prometheus.exporters.kea.port} counter accept comment "prometheus-kea-exporter: accept from stats.ffrn.de"
      ip saddr { 5.189.157.196/32 } tcp dport ${toString config.services.prometheus.exporters.kea.port} counter accept comment "prometheus-kea-exporter: accept from stats.ffrn.de"
    '';
  };


  networking.nftables.tables.nixos-fw = {
    content = ''
      chain input_extra {
        tcp dport ${toString config.services.fastd-exporter.port} ip saddr { 5.189.157.196/32 } counter accept comment "fastd-exporter: accept from stats.ffrn.de"
        tcp dport ${toString config.services.fastd-exporter.port} ip6 saddr { 2a02:c207:3001:370::/64 } counter accept comment "fastd-exporter: accept from stats.ffrn.de"
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

  systemd.network.networks."10-mainif".networkConfig.VXLAN = config.modules.freifunk.gateway.vxlan.interfaceNames;

  services.fastd-peergroup-nodes = {
    enable = true;
    reloadServices = map (service: "${service.unitName}.service") (builtins.attrValues config.services.fastd);
    repoUrl = "git@github.com:Freifunk-Rhein-Neckar/fastd-keys.git";
    repoBranch = "master";
    sshCommand = "${pkgs.openssh}/bin/ssh -i ${config.age.secrets."id_ed25519_fastdkeys".path}";
  };
}
