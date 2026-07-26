{ pkgs, ... }: {
  home = {
    packages = [ pkgs.w3m ];

    file = {
      ".w3m/config".text = ''
        confirm_qq 0
        use_history 0
      '';

      ".w3m/keymap".text = ''
        keymap C-d NEXT_HALF_PAGE
        keymap C-u PREV_HALF_PAGE
      '';
    };
  };
}
