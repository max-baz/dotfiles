{ config, ... }: {
  home-manager.users.${config.user}.xdg.configFile."sworkstyle/config.toml".text = ''
    fallback = ""

    [matching]
    "calibre-gui" = ""
    "chromium" = ""
    "chromium-browser" = ""
    "code" = ""
    "dmenu" = ""
    "dmenu-clipboard" = ""
    "dmenu-browser" = ""
    "dmenu-emoji" = ""
    "dmenu-pass generator" = ""
    "firefox" = ""
    "kitty" = ""
    "krita" = ""
    "org.gnumeric.gnumeric" = ""
    "abiword" = ""
    "mindwtr" = ""
    "mpv" = ""
    "aerc" = ""
    "org.pwmt.zathura" = ""
    "pavucontrol" = ""
    "peek" = ""
    "qalculate-gtk" = ""
    "signal" = ""
    "swappy" = ""
    "vimiv" = ""
    "thunderbird" = ""
  '';
}
