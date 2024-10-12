{ config, lib, pkgs, name, ... }:
let
  user = "nebula-ffrn";

in {

  age.secrets."nebula-ca.crt" = {
    file = ../../secrets/nebula-ca.crt.age;
    mode = "0400";
    owner = user;
    group = user;
  };

  age.secrets."nebula-host.crt" = {
    file = ../../secrets/${name}/nebula-host.crt.age;
    mode = "0400";
    owner = user;
    group = user;
  };

  age.secrets."nebula-host.key" = {
    file = ../../secrets/${name}/nebula-host.key.age;
    mode = "0400";
    owner = user;
    group = user;
  };

  services.nebula.networks."ffrn" = {
    enable = true;
    tun.device = "nebula.ffrn";
    ca = config.age.secrets."nebula-ca.crt".path;
    cert = config.age.secrets."nebula-host.crt".path;
    key = config.age.secrets."nebula-host.key".path;
    staticHostMap = {
      "192.168.100.1" = ["49.12.39.108:4242" "[2a01:4f8:c17:6b7f::1]:4242" ];
    };
    lighthouses = [
      "192.168.100.1"
    ];
    listen = {
      host = "::";
    };
    firewall = {
      outbound = [
        {
          host = "any";
          port = "any";
          proto = "any";
        }
      ];
      inbound = [
        {
          host = "any";
          port = "any";
          proto = "icmp";
        }
        {
          host = "any";
          port = 5201;
          proto = "tcp";
        }
        {
          host = "any";
          port = 5201;
          proto = "udp";
        }
        {
          host = "any";
          port = 9100;
          proto = "tcp";
          groups = [ "noc" "prometheus" ];
        }
        {
          host = "any";
          port = 22;
          proto = "tcp";
          groups = [ "noc" ];
        }

        {
          host = "any";
          port = "any";
          proto = "tcp";
          groups = [ "noc" ];
        }
      ];
    };
    settings = {
      punchy = {
        punch = true;
        respond = true;
      };
      sshd = {
        enabled = true;
        listen = "127.0.0.1:2222";

        host_key = "/etc/ssh/nebula_host_ed25519_key";
        authorized_users = [{
          user = "root";
          keys = config.users.users.root.openssh.authorizedKeys.keys;
        }];
      };
    };
  };

  networking.firewall.interfaces."nebula.ffrn".allowedUDPPorts = [ 5201 ];
  networking.firewall.interfaces."nebula.ffrn".allowedTCPPorts = [ 5201 ];


  systemd.services."nebula@ffrn".serviceConfig = {
    ExecStartPre = "+${pkgs.bash}/bin/bash -c " + pkgs.writeScript "create-ssh-keys" ''
      FILE="/etc/ssh/nebula_host_ed25519_key"

      if [ ! -f "$FILE" ]; then
        ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f $FILE -N "" < /dev/null
      fi

      ${pkgs.coreutils}/bin/chown ${user} $FILE
    '';
    User = user;
    ReadOnlyPaths = [ "/etc/ssh/nebula_host_ed25519_key" ];
  };

}
