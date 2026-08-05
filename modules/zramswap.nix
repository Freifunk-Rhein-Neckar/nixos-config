{ config, lib, pkgs, ... }:
{
  boot.kernel.sysctl."vm.swappiness" = 180;
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };
}
