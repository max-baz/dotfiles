{ pkgs, ... }: {
  home.packages = [ pkgs.swappy ];

  xdg.configFile."swappy/config".text = ''
    [Default]
    save_dir=/tmp/screenshots
    paint_mode=arrow
    early_exit=true
  '';
}
