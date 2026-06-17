{ config, pkgs, ... }:
{
  users.users.build-tom = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdnwVGpMaBv5Bx2XuIvuBI+b4HNaPYcuPoGSzZi/Z5R ffrn@tomh v1"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILp4HgDDRQYOp1xXPTUkqv83dZw+DGIj5jZdBzR2u57Y tom@tomh v6"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5g4W9Sq6zk1HOz70VWHhrYTcIDhL5mauv6uBXzVL9t root@tom-laptop3"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJWo8RHWi3Ulv38FLja4GJDxgGToxeKUoUl0KPIS0Bu7 root@zeus"
    ];
  };

  nix.settings.trusted-users = [ "build-tom" ];
}
