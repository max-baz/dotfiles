{
  security = {
    rtkit.enable = true;
    polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function (action, subject) {
          if (
            (action.id == "org.debian.pcsc-lite.access_pcsc" ||
            action.id == "org.debian.pcsc-lite.access_card") &&
            subject.isInGroup("wheel")
          ) {
            return polkit.Result.YES;
          }
        });
      '';
    };

    pam = {
      ### SETUP
      # mkdir -p ~/.config/Yubico
      # pamu2fcfg >> ~/.config/Yubico/u2f_keys
      services.sudo.u2fAuth = true;
      services.polkit-1.u2fAuth = true;
      u2f.settings.cue = true;
    };
  };

  services.pcscd.enable = true;
}
