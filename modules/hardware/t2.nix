{
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
}
