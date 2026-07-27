{ inputs, mkModuleArgs, nixpkgsConfig, ... }:
let
  system = "x86_64-linux";
  user = "max.baz@canonical.com";
  moduleArgs = mkModuleArgs system;
  pkgs = import inputs.nixpkgs {
    inherit system;
    config = nixpkgsConfig;
  };
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = moduleArgs;
  modules = [
    { user = user; }
    inputs.nix-index-database.homeModules.nix-index
    ../../modules/common/home
    {
      home.username = user;
      home.homeDirectory = "/home/${user}";
    }
  ];
}
