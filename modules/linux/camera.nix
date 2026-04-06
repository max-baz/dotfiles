{ config, ... }: {
  programs.gphoto2.enable = true;
  users.users.${config.user}.extraGroups = [ "camera" ];

  boot = {
    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    extraModprobeConfig = ''
      options v4l2loopback video_nr=10 card_label="gphoto2" exclusive_caps=1 max_buffers=2
    '';
  };
}
