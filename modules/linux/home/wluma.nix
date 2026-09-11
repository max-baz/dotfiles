{ lib, pkgs, util, ... }: {
  # ddcutil-service is started on demand through its D-Bus activation file.
  home.packages = with pkgs; [
    ddcutil
    ddcutil-service
    wluma
  ];

  systemd.user.services.wluma = util.systemdService {
    Description = "wluma";
    ExecStart = lib.getExe pkgs.wluma;
  };
}
