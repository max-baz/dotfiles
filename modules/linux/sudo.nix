{
  security.sudo = {
    enable = true;

    extraConfig = ''
      Defaults timestamp_timeout=0
      Defaults passwd_timeout=0
    '';

    extraRules = [{
      groups = [ "wheel" ];
      commands = [
        { command = "/run/current-system/sw/bin/resolvectl dnsovertls wlan0 yes"; options = [ "SETENV" "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/resolvectl dns wlan0 *"; options = [ "SETENV" "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/resolvectl revert wlan0"; options = [ "SETENV" "NOPASSWD" ]; }
        { command = "/run/current-system/sw/bin/systemctl stop pcscd.service"; options = [ "SETENV" "NOPASSWD" ]; }
      ];
    }];
  };
}
