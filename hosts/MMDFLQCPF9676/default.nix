{ inputs, globals, ... }:
inputs.nix-darwin.lib.darwinSystem rec {
  system = "aarch64-darwin";
  specialArgs = {
    util = (import ../../util);
    firefox-addons = inputs.firefox-addons.packages.${system};
  };
  modules = [
    globals
    inputs.dotfiles-private.nixosModules.macos
    inputs.mac-app-util.darwinModules.default
    inputs.home-manager.darwinModules.home-manager
    ../../modules/macos
    {
      nixpkgs.overlays = [ inputs.firefox-darwin.overlay ];

      home-manager.users.${globals.user}.imports = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.nix-index-database.homeModules.nix-index
      ];
    }
  ];
}
