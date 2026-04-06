{ config, ... }: {
  home-manager.users.${config.user} = {
    gtk.enable = true;
    gtk.gtk3.extraConfig = { gtk-application-prefer-dark-theme = true; };
    gtk.gtk4.extraConfig = { gtk-application-prefer-dark-theme = true; };
    gtk.gtk4.theme = null;
    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
}
