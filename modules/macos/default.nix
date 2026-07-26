{
  # See here what bumping this value impacts: https://github.com/LnL7/nix-darwin/blob/master/CHANGELOG
  system.stateVersion = 4;

  imports = [
    ../common/nixos
    ./homebrew.nix
    ./packages.nix
    ./system.nix
    ./touch-id.nix
    ./users.nix
  ];
}
