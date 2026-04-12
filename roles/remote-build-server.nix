{ config, pkgs, ... }:
{
  users.users.build-tom = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdnwVGpMaBv5Bx2XuIvuBI+b4HNaPYcuPoGSzZi/Z5R ffrn@tomh v1"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILp4HgDDRQYOp1xXPTUkqv83dZw+DGIj5jZdBzR2u57Y tom@tomh v6"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMCK8LTP9ElXbQqCsvAMSd0G9l6a/Oneh+k3ocPsSa4H root@tom-laptop2"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhYQY4ydpa0w6+1+7O2cXEDBdlYMgYeLT9UCSO5t74/ root@tom-zeus"
    ];
  };

  nix.settings.trusted-users = [ "build-tom" ];
}