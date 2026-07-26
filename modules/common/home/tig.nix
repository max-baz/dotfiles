{ pkgs, ... }: {
  xdg.configFile."tig/config".text = ''
    set line-graphics = utf-8
    set tab-size = 4
    set diff-highlight = ${pkgs.git}/share/git/contrib/diff-highlight/diff-highlight

    color cursor 15 blue
    set main-view = date:relative id:yes author:full commit-title:yes,graph,refs,overflow=no
  '';
}
