{ pkgs, ... }: {
  home = {
    packages = [ pkgs.go ];

    sessionPath = [ "$HOME/go/bin" ];
  };
}
