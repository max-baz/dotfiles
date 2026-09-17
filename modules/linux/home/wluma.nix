{ config, lib, pkgs, util, ... }:
let
  wluma = if config.targets.genericLinux.enable then config.lib.nixGL.wrap pkgs.wluma else pkgs.wluma;
in {
  # ddcutil-service is started on demand through its D-Bus activation file.
  home.packages = with pkgs; [
    ddcutil
    ddcutil-service
    wluma
  ];

  systemd.user.services.wluma = util.systemdService {
    Description = "wluma";
    ExecStart = lib.getExe wluma;
  };
}
