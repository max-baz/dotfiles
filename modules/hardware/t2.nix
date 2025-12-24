{ lib, pkgs, ... }: {
  nix.settings = {
    extra-substituters = [ "https://cache.soopy.moe" ];
    extra-trusted-public-keys = [ "cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo=" ];
  };

  # low power for the dGPU
  services.udev.extraRules = ''
    SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="low"
  '';

  # to prevent sway detecting fake second output
  environment.sessionVariables.WLR_DRM_DEVICES = "/dev/dri/card1";

  boot = {
    loader.efi.canTouchEfiVariables = true;

    # prefer iGPU
    kernelParams = [ "i915.enable_guc=2" ];

    extraModprobeConfig = ''
      options hid_apple swap_opt_cmd=1 swap_fn_leftctrl=1 iso_layout=1
      options hid-appletb-kbd mode=1
      options apple-gmux force_igd=y
    '';
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  systemd.services = lib.genAttrs [
    "systemd-suspend"
    "systemd-hybrid-sleep"
    "systemd-hibernate"
    "systemd-suspend-then-hibernate"
  ]
    (name: {
      serviceConfig = {
        Environment = "SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false";

        ExecStartPre = [
          "-${lib.getExe' pkgs.kmod "rmmod"} -f hid-appletb-kbd"
          "-${lib.getExe' pkgs.kmod "rmmod"} -f hid-appletb-bl"
          "-${lib.getExe' pkgs.kmod "rmmod"} -f apple-bce"
        ];

        ExecStartPost = [
          "${lib.getExe' pkgs.coreutils "sleep"} 4"
          "${lib.getExe' pkgs.kmod "modprobe"} apple-bce"
          "${lib.getExe' pkgs.coreutils "sleep"} 4"
          "${lib.getExe' pkgs.kmod "modprobe"} hid-appletb-bl"
          "${lib.getExe' pkgs.coreutils "sleep"} 2"
          "${lib.getExe' pkgs.kmod "modprobe"} hid-appletb-kbd"
        ];
      };
    });
}
