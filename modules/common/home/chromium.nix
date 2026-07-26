{ config, pkgs, ... }: {
  programs.chromium = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.chromium;
  };
}
