{ config, pkgs, ... }: {
  home-manager.users.${config.user} = {
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Input" ];
        emoji = [ "JoyPixels" ];
      };
    };

    xdg.configFile."fontconfig/conf.d/01-emoji.conf".text = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <match target="pattern">
          <test name="family"><string>Noto Color Emoji</string></test>
          <edit name="family" mode="assign" binding="same"><string>JoyPixels</string></edit>
        </match>

        <match target="pattern">
          <test name="family"><string>Apple Color Emoji</string></test>
          <edit name="family" mode="assign" binding="same"><string>JoyPixels</string></edit>
        </match>

        <match target="pattern">
          <test name="family"><string>Segoe UI Emoji</string></test>
          <edit name="family" mode="assign" binding="same"><string>JoyPixels</string></edit>
        </match>
      </fontconfig>
    '';

    home.packages = with pkgs; [
      font-awesome
      input-fonts
      joypixels
      nerd-fonts.symbols-only
      open-sans
    ];
  };
}
