{ config, pkgs, lib, ... }:
{

  services.chrony = {
    enable = true;
    extraConfig = ''
      allow all
    '';
  };

  networking.firewall.extraInputRules = ''
    udp dport 123 meter ntp6 { ip6 saddr limit rate 10/second burst 20 packets } counter accept comment "allow chrony"
  '';
}
