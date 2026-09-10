{ config, lib, pkgs, util, ... }: {
  services.udev.extraRules = ''
    SUBSYSTEM=="backlight", ACTION=="add", \
      RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness", \
      RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
    SUBSYSTEM=="leds", ACTION=="add", \
      RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/leds/%k/brightness", \
      RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness"
  '';

  home-manager.users.${config.user} = {
    home.packages = with pkgs; [ wluma ddcutil ddcutil-service ];

    systemd.user.services.wluma = util.systemdService {
      Description = "wluma";
      ExecStart = "${lib.getExe pkgs.wluma}";
    };
  };
}
