{ pkgs, stable, ... }: {
  home.packages = with pkgs; [
    stable.awscli
    stable.azure-cli
  ];
}

