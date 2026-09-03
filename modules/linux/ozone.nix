{ lib, pkgs, ... }: {
  config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
