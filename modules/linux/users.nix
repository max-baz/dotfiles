{ config, pkgs, ... }: {
  users.users.${config.user} = {
    password = "CHANGEME";
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "input" ];
    shell = pkgs.zsh;
    uid = 1000;
  };

  systemd.services."getty@tty1" = {
    overrideStrategy = "asDropin";
    serviceConfig.ExecStart = [
      ""
      "@${pkgs.util-linux}/sbin/agetty agetty --autologin ${config.user} --noclear %I $TERM"
    ];
  };
}
