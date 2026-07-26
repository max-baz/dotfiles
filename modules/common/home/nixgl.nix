{ nixgl, pkgs, ... }: {
  targets.genericLinux.enable = true;
  targets.genericLinux.nixGL.packages = nixgl.packages;
  targets.genericLinux.nixGL.defaultWrapper = "mesa";

  home.packages = [
    nixgl.packages.${pkgs.system}.nixGLIntel
  ];

  # Force Mesa to enable driver support for newer Intel GPUs
  systemd.user.sessionVariables = {
    INTEL_FORCE_PROBE = "*";
  };
}
