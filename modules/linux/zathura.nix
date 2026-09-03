{ config, ... }: {
  home-manager.users.${config.user}.programs.zathura = {
    enable = true;
    options.selection-clipboard = "clipboard";
  };
}
