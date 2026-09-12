{ config, lib, pkgs, ... }:
{
  services.draupnir = {
    enable = true;
    settings = {
      automaticallyRedactForReasons = [ "spam" "advertising" "no reason provided" ];

      managementRoom = "#moderation:ffrn.de";

      homeserverUrl = "https://matrix.ffrn.de";
    };

    secrets.accessToken = config.age.secrets."draupnir-accessToken".path;
  };

  age.secrets."draupnir-accessToken" = {
    file = ../../secrets/matrixbot/draupnir-accessToken.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };

}