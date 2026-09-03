{ config, pkgs, ... }: {
  programs.kitty = {
    enable = true;
    package = if config.targets.genericLinux.enable then config.lib.nixGL.wrap pkgs.kitty else pkgs.kitty;
    themeFile = "gruvbox-dark-hard";
    font = {
      name = "Input";
      size = if pkgs.stdenv.hostPlatform.isLinux then 9 else 12;
    };

    settings = {
      allow_remote_control = true;
      close_on_child_death = true;
      cursor_shape = "beam";
      enable_audio_bell = false;
      listen_on = if pkgs.stdenv.hostPlatform.isLinux then "unix:@kitty" else "unix:/tmp/kitty";
      mouse_hide_wait = 0;
      scrollback_lines = 100000;
      strip_trailing_spaces = "always";
      symbol_map = "U+E005,U+E00D,U+E041,U+E059-U+E076,U+E085-U+E086,U+E097-U+E098,U+E09A,U+E0A9,U+E0AC,U+E0B4,U+E0B7,U+E0D8,U+E0DF,U+E0E3-U+E0E4,U+E131,U+E139-U+E13C,U+E140,U+E152,U+E169,U+E16D,U+E17B,U+E184,U+E18F,U+E19A-U+E19B,U+E1A8,U+E1B0,U+E1BC,U+E1C4,U+E1C8,U+E1D3,U+E1D5,U+E1D7,U+E1ED,U+E1F6,U+E209,U+E221-U+E222,U+E23D,U+E289,U+E29C,U+E2BB,U+E2C5,U+E2CA,U+E3AF,U+E3B1-U+E3B2,U+E3F5,U+E43C,U+E445,U+E447-U+E448,U+E46C,U+E476-U+E477,U+E47A-U+E47B,U+E490,U+E4A8-U+E4A9,U+F000-U+F00E,U+F010-U+F01E,U+F021-U+F03E,U+F040-U+F04E,U+F050-U+F05E,U+F060-U+F06E,U+F070-U+F07E,U+F080,U+F083-U+F08B,U+F08D-U+F08E,U+F090-U+F091,U+F093-U+F098,U+F09C-U+F09E,U+F0A0-U+F0AE,U+F0B0-U+F0B2,U+F0C0-U+F0CE,U+F0D0-U+F0D1,U+F0D6-U+F0DE,U+F0E0,U+F0E2-U+F0EE,U+F0F0-U+F0FE,U+F100-U+F10E,U+F110-U+F112,U+F114-U+F115,U+F118-U+F11E,U+F120-U+F12E,U+F130-U+F135,U+F137-U+F13A,U+F13D-U+F13E,U+F140-U+F14E,U+F150-U+F159,U+F15B-U+F15E,U+F160-U+F165,U+F175-U+F178,U+F182-U+F183,U+F185-U+F188,U+F18E,U+F190-U+F193,U+F195-U+F197,U+F199,U+F19C-U+F19D,U+F1AB-U+F1AE,U+F1B0-U+F1B3,U+F1B8-U+F1BB,U+F1C0-U+F1C9,U+F1CD-U+F1CE,U+F1D8-U+F1DE,U+F1E0-U+F1E6,U+F1EA-U+F1EC,U+F1F6-U+F1FE,U+F200-U+F201,U+F204-U+F207,U+F20A-U+F20B,U+F217-U+F21E,U+F221-U+F22D,U+F233-U+F236,U+F238-U+F239,U+F240-U+F24A,U+F24D-U+F24E,U+F250-U+F25D,U+F26C,U+F271-U+F27B,U+F283,U+F28B-U+F28E,U+F290-U+F292,U+F295,U+F29A,U+F29C-U+F29E,U+F2A0-U+F2A4,U+F2A7-U+F2A8,U+F2B4-U+F2B7,U+F2B9-U+F2BE,U+F2C0-U+F2C3,U+F2C7-U+F2CE,U+F2D0-U+F2D4,U+F2DB-U+F2DC,U+F2E5,U+F2E7,U+F2EA,U+F2ED,U+F2F1-U+F2F2,U+F2F5-U+F2F6,U+F2F9,U+F2FE,U+F302-U+F305,U+F309-U+F30C,U+F31E,U+F328,U+F332,U+F337-U+F338,U+F358-U+F35B,U+F35D,U+F360,U+F362-U+F363,U+F381-U+F382,U+F386-U+F387,U+F390,U+F3A5,U+F3BE-U+F3BF,U+F3C1,U+F3C5,U+F3C9,U+F3CD-U+F3CE,U+F3D1,U+F3DD,U+F3E0,U+F3E5,U+F3ED,U+F3FA-U+F3FB,U+F3FD,U+F3FF,U+F406,U+F410,U+F422,U+F424,U+F432-U+F434,U+F436,U+F439-U+F43A,U+F43C,U+F43F,U+F441,U+F443,U+F445,U+F447,U+F44B,U+F44E,U+F450,U+F453,U+F458,U+F45C-U+F45D,U+F45F,U+F461-U+F462,U+F466,U+F468-U+F46D,U+F470-U+F472,U+F474,U+F477-U+F479,U+F47D-U+F47F,U+F481-U+F482,U+F484-U+F487,U+F48B,U+F48D-U+F48E,U+F490-U+F494,U+F496-U+F497,U+F49E,U+F4A1,U+F4AD,U+F4B3,U+F4B8-U+F4BA,U+F4BD-U+F4BE,U+F4C0-U+F4C2,U+F4C4,U+F4CD-U+F4CE,U+F4D3,U+F4D6-U+F4DB,U+F4DE-U+F4DF,U+F4E2-U+F4E3,U+F4E6,U+F4FA-U+F509,U+F515-U+F591,U+F593-U+F59D,U+F59F-U+F5A2,U+F5A4-U+F5A7,U+F5AA-U+F5B1,U+F5B3-U+F5B4,U+F5B6-U+F5B8,U+F5BA-U+F5BD,U+F5BF-U+F5C5,U+F5C7-U+F5CB,U+F5CD-U+F5CE,U+F5D0-U+F5D2,U+F5D7,U+F5DA,U+F5DC,U+F5DE-U+F5DF,U+F5E1,U+F5E4,U+F5E7,U+F5EB,U+F5EE,U+F5FC-U+F5FD,U+F601,U+F604,U+F610,U+F613,U+F619,U+F61F,U+F621,U+F624-U+F625,U+F629-U+F62A,U+F62E-U+F630,U+F637,U+F63B-U+F63C,U+F641,U+F644,U+F647,U+F64A,U+F64F,U+F651,U+F653-U+F655,U+F658,U+F65D-U+F65E,U+F662,U+F664-U+F666,U+F669-U+F66B,U+F66D,U+F66F,U+F674,U+F676,U+F678-U+F679,U+F67B-U+F67C,U+F67F,U+F681-U+F684,U+F687-U+F689,U+F696,U+F698-U+F69B,U+F6A0-U+F6A1,U+F6A7,U+F6A9,U+F6AD,U+F6B6-U+F6B7,U+F6BB,U+F6BE,U+F6C0,U+F6C3-U+F6C4,U+F6CF,U+F6D1,U+F6D3,U+F6D5,U+F6D7,U+F6D9,U+F6DD-U+F6DE,U+F6E2-U+F6E3,U+F6E6,U+F6E8,U+F6EC-U+F6ED,U+F6F0-U+F6F2,U+F6FA,U+F6FC,U+F6FF-U+F700,U+F70B-U+F70C,U+F70E,U+F714-U+F715,U+F717,U+F71E,U+F722,U+F728-U+F729,U+F72B,U+F72E-U+F72F,U+F73B-U+F73D,U+F740,U+F743,U+F747,U+F74D,U+F753,U+F756,U+F75A-U+F75B,U+F75E-U+F75F,U+F769,U+F76B,U+F772-U+F773,U+F77C-U+F77D,U+F780-U+F781,U+F783-U+F784,U+F786-U+F788,U+F78C,U+F793-U+F794,U+F796,U+F79C,U+F79F-U+F7A0,U+F7A2,U+F7A4-U+F7A6,U+F7A9-U+F7AB,U+F7AD-U+F7AE,U+F7B5-U+F7B6,U+F7B9-U+F7BA,U+F7BD,U+F7BF-U+F7C0,U+F7C2,U+F7C4-U+F7C5,U+F7C9-U+F7CA,U+F7CC-U+F7CE,U+F7D0,U+F7D2,U+F7D7-U+F7DA,U+F7E4-U+F7E6,U+F7EC,U+F7EF,U+F7F2,U+F7F5,U+F7F7,U+F7FA-U+F7FB,U+F802,U+F805-U+F807,U+F80A-U+F80D,U+F80F-U+F810,U+F812,U+F815-U+F816,U+F818,U+F828-U+F82A,U+F82F,U+F83E,U+F84A,U+F84C,U+F850,U+F853,U+F863,U+F86D,U+F879,U+F87B-U+F87D,U+F881-U+F882,U+F884-U+F887,U+F891,U+F897,U+F8C0-U+F8C1,U+F8CC,U+F8D9,U+F8E5,U+F8FF Font Awesome 7 Free Solid";
      touch_scroll_multiplier = 20;

      macos_option_as_alt = true;
      macos_quit_when_last_window_closed = true;
      macos_show_window_title_in = "window";
      remember_window_size = false;
      initial_window_width = 1000;
      initial_window_height = 600;
    };

    keybindings = {
      "kitty_mod+b" = "launch --type overlay --stdin-source=@screen_scrollback hx";
      "kitty_mod+n" = if pkgs.stdenv.hostPlatform.isLinux then "launch --type=background --cwd=current cglaunch kitty --detach" else "new_os_window_with_cwd";
      "kitty_mod+u" = '' launch --type window --allow-remote-control sh -c 'kitty @ send-text -m id:1 "\e[200~$(emoji-dmenu -k overlay)\e[201~"' '';
      "kitty_mod+г" = '' launch --type window --allow-remote-control sh -c 'kitty @ send-text -m id:1 "\e[200~$(emoji-dmenu -k overlay)\e[201~"' '';
      "kitty_mod+i" = '' launch --type window --allow-remote-control sh -c 'kitty @ send-text -m id:1 "\e[200~$(wl-clipboard-manager dmenu -k overlay)\e[201~"' '';
      "kitty_mod+ш" = '' launch --type window --allow-remote-control sh -c 'kitty @ send-text -m id:1 "\e[200~$(wl-clipboard-manager dmenu -k overlay)\e[201~"' '';
      "kitty_mod+0" = "change_font_size all 0";
      "kitty_mod+с" = "copy_to_clipboard";
      "kitty_mod+м" = "paste_from_clipboard";
    };
  };
}
