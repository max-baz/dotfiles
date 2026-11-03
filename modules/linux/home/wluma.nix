{ config, lib, pkgs, util, wluma-src, ... }:
let
  useLatest = true;
  package = if useLatest then wluma-src.defaultPackage.${pkgs.stdenv.hostPlatform.system} else pkgs.wluma;
  wluma = if config.targets.genericLinux.enable then config.lib.nixGL.wrap package else package;
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
