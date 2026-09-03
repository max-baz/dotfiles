{ config, lib, ... }:
let
  v4l2loopback-ctl = "${config.boot.kernelPackages.v4l2loopback.bin}/bin/v4l2loopback-ctl";
in
{
  programs.gphoto2.enable = true;

  users.users.${config.user}.extraGroups = [ "camera" ];

  boot = {
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    extraModprobeConfig = lib.mkDefault "options v4l2loopback devices=0";
  };

  systemd.services.gphoto2-v4l2loopback = {
    description = "gPhoto2 v4l2loopback device";
    wants = [ "modprobe@v4l2loopback.service" ];
    after = [ "modprobe@v4l2loopback.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${v4l2loopback-ctl} add -b 2 -x 1 -n gphoto2 /dev/video99";
      ExecStop = "${v4l2loopback-ctl} delete /dev/video99";
    };
  };
}
