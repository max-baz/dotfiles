{ inputs, globals, ... }:
let
  extraArgs = { pkgs, ... }: {
    _module.args.stable = import inputs.stable {
      inherit (pkgs) config overlays;
      localSystem = pkgs.stdenv.hostPlatform;
    };
    _module.args.unstable-small = import inputs.unstable-small {
      inherit (pkgs) config overlays;
      localSystem = pkgs.stdenv.hostPlatform;
    };
    _module.args.util = (import ../../util);
    _module.args.firefox-addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
    _module.args.waysip = inputs.waysip.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
in
inputs.nixpkgs.lib.nixosSystem {
  modules = [
    globals
    extraArgs
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
