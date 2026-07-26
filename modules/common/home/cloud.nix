{ pkgs, ... }: {
  home.packages = with pkgs; [
    awscli
    azure-cli
  ];
}

