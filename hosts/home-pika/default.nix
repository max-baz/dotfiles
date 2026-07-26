{ inputs, globals, ... }:
let
  system = "x86_64-linux";
  nixpkgsConfig = {
    allowUnfree = true;
    input-fonts.acceptLicense = true;
    joypixels.acceptLicense = true;
  };
  extraArgs = {
    _module.args.stable = import inputs.stable {
      inherit system;
      config = nixpkgsConfig;
    };
    _module.args.unstable-small = import inputs.unstable-small {
      inherit system;
      config = nixpkgsConfig;
    };
    _module.args.util = (import ../../util);
    _module.args.firefox-addons = inputs.firefox-addons.packages.${system};
    _module.args.waysip = inputs.waysip.packages.${system}.default;
  };
in
inputs.nixpkgs.lib.nixosSystem {
  modules = [
    globals
    extraArgs
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.dell-xps-14-da14260
    inputs.sops-nix.nixosModules.sops
    inputs.dotfiles-private.nixosModules.linux
    inputs.home-manager.nixosModules.home-manager
    ../../modules/linux
    ../../modules/hardware/intel-graphics.nix
    inputs.lanzaboote.nixosModules.lanzaboote
    ../../modules/hardware/secure-boot.nix
    {
      personal.enable = true;

      networking.hostName = "home-pika";

      home-manager.users.${globals.user}.imports = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.nix-index-database.homeModules.nix-index
      ];
    }
  ];
}
