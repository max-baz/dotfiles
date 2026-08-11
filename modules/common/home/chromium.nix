{ config, pkgs, ... }: {
  programs.chromium = {
    enable = true;
    package = if config.targets.genericLinux.enable then config.lib.nixGL.wrap pkgs.chromium else pkgs.chromium;
  };
}
