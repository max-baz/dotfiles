{ lib, ... }: {
  # silent systemd boot
  boot = {
    loader.systemd-boot.enable = true;
    kernelParams = [
      "quiet"
      "splash"
      "systemd.show_status=false"
      "rd.systemd.show_status=false"
      "udev.log_priority=3"
      "rd.udev.log_priority=3"
      "vt.global_cursor_default=0"
    ];
    consoleLogLevel = 3;
    plymouth.enable = true;
    initrd = {
      systemd.enable = true;
      verbose = false;
    };
  };

  systemd.mounts = [{
    what = "tmpfs";
    where = "/tmp";
    type = "tmpfs";
    mountConfig.Options = lib.concatStringsSep "," [
      "mode=1777"
      "strictatime"
      "rw"
      "nosuid"
      "nodev"
      "size=50G"

      # increase inodes, boot.tmp.useTmpfs cannot do this
      "nr_inodes=5000000"
    ];
  }];
}
