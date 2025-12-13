{ inputs, globals, ... }:
let
  stable = { config, pkgs, ... }: {
    _module.args.stable = import inputs.stable {
      inherit (pkgs.stdenv.hostPlatform) system;
      inherit (config.nixpkgs) config;
    };
  };
  unstable-small = { config, pkgs, ... }: {
    _module.args.unstable-small = import inputs.unstable-small {
      inherit (pkgs.stdenv.hostPlatform) system;
      inherit (config.nixpkgs) config;
    };
  };
in
inputs.nixpkgs.lib.nixosSystem rec {
  system = "x86_64-linux";
  specialArgs = {
    util = (import ../../util);
    firefox-addons = inputs.firefox-addons.packages.${system};
    waysip = inputs.waysip.packages.${system}.default;
  };
  modules = [
    globals
    stable
    unstable-small
    ./firmware.nix
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.apple-t2
    inputs.sops-nix.nixosModules.sops
    inputs.dotfiles-private.nixosModules.linux
    inputs.home-manager.nixosModules.home-manager
    ../../modules/linux
    ../../modules/hardware/t2.nix
    {
      personal.enable = true;

      networking.hostName = "home-titan";

      home-manager.users.${globals.user}.imports = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.nix-index-database.homeModules.nix-index
      ];
    }
  ];
}
