{ pkgs, ... }: {
  home.packages = with pkgs; [
    p7zip
    pigz
    unrar
    unzip
    zip
  ];
}

