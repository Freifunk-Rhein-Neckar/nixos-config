{ config, lib, pkgs, ... }:
{
  services.nebula.networks."ffrn" = {
    isRelay = true;
    isLighthouse = true;
    settings = {
      relay = {
        use_relays = false;
        relays = [];
      };
    };
  };
}
