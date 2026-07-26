{
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--iglob=!.git"
    ];
  };
}
