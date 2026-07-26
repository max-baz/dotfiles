{ config, pkgs, ... }: {
  home-manager.users.${config.user}.home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
  };
}
