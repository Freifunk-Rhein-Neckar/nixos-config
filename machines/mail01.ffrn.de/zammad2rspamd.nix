{ config, lib, pkgs, name, ... }:
{
  imports = [
    ../../modules/zammad2rspamd
  ];

  services.zammad2rspamd = {
    enable = true;
    rspamdUrl = "https://rspamd.int.ffrn.de";
    zammadUrl = "https://tickets.ffrn.de/";
    zammadTokenFile = config.age.secrets."zammad-spam-handler-token".path;
    lastUpdatedHours = 0;
    interval = "*:0/15";
  };

  age.secrets."zammad-spam-handler-token" = {
    file = ../../secrets/${name}/zammad-spam-handler-token.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

}
