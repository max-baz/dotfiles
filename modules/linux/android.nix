{ config, pkgs, ... }: {
  home-manager.users.${config.user}.home.packages = with pkgs; [ android-tools ];
  users.users.${config.user}.extraGroups = [ "adbusers" ];
}
