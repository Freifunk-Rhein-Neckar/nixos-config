{ config, lib, pkgs, ... }:
{
  services.nebula.networks."ffrn" = {
    isRelay = true;
    isLighthouse = true;
  };
}
