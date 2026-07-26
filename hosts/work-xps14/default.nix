{ inputs, ... }:
let
  system = "x86_64-linux";
  nixpkgsConfig = {
    allowUnfree = true;
    input-fonts.acceptLicense = true;
    joypixels.acceptLicense = true;
  };
  pkgs = import inputs.nixpkgs {
    inherit system;
    config = nixpkgsConfig;
  };
  user = "max.baz@canonical.com";
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = {
    nixgl = inputs.nixgl;
    stable = import inputs.stable { inherit system; config = nixpkgsConfig; };
    unstable-small = import inputs.unstable-small { inherit system; config = nixpkgsConfig; };
    util = (import ../../util);
    firefox-addons = inputs.firefox-addons.packages.${system};
  };
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
