{ config, ... }: {
  home-manager.users.${config.user}.programs.chromium.enable = true;
}
