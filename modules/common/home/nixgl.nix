{ isNixOS, lib, nixgl, pkgs, ... }:
let enable = pkgs.stdenv.isLinux && !isNixOS;
in {
  targets.genericLinux.enable = enable;
  targets.genericLinux.nixGL.packages = lib.mkIf enable nixgl.packages;
  targets.genericLinux.nixGL.defaultWrapper = "mesa";

  home.packages = lib.optionals enable [
    nixgl.packages.${pkgs.stdenv.hostPlatform.system}.nixGLIntel
  ];

  # Force Mesa to enable driver support for newer Intel GPUs
  systemd.user.sessionVariables = lib.mkIf enable {
    INTEL_FORCE_PROBE = "*";
  };
}
