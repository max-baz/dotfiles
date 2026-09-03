{ config, lib, pkgs, util, ... }: {
  home-manager.users.${config.user}.systemd.user.services = {
    battery-low-notify = util.systemdService {
      Description = "Notify when battery level is low";
      ExecStart = lib.getExe' pkgs.maximbaz-scripts "battery-low-notify";
    };

    push2talk = util.systemdService {
      Description = "push2talk";
      Environment = [ "PUSH2TALK_KEYBIND=Super_R" ];
      ExecStart = lib.getExe pkgs.push2talk;
    };

    sway-inactive-windows-transparency = util.systemdService {
      Description = "Make inactive windows in sway semi-transparent";
      Environment = [ "INACTIVE_OPACITY=0.7" ];
      ExecStart = lib.getExe pkgs.sway-contrib.inactive-windows-transparency;
    };

    sway-unfullscreen = util.systemdService {
      Description = "Unfullscreen sway when opening another window";
      ExecStart = lib.getExe' pkgs.maximbaz-scripts "sway-unfullscreen";
    };

    wl-clipboard-manager = util.systemdService {
      Description = "Clipboard manager daemon";
      ExecStart = "${lib.getExe' pkgs.maximbaz-scripts "wl-clipboard-manager"} daemon";
    };

    workstyle = util.systemdService {
      Description = "Autoname sway workspaces";
      ExecStart = "${lib.getExe pkgs.swayest-workstyle} --deduplicate";
    };

    ntfy = util.systemdService {
      Description = "Subscribe for push notifications";
      Environment = with pkgs; [ "PATH=${lib.makeBinPath [ bash libnotify ntfy-sh ]}" ];
      ExecStart = "${lib.getExe' pkgs.ntfy-sh "ntfy"} subscribe --from-config";
    };
  };
}
