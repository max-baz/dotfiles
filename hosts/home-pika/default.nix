{ inputs, mkModuleArgs, ... }:
let
  system = "x86_64-linux";
  user = "max";
  moduleArgs = mkModuleArgs system;
in
inputs.nixpkgs.lib.nixosSystem {
  specialArgs = moduleArgs;
  modules = [
    { inherit user; }
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
      networking.hostName = "home-pika";

      home-manager = {
        extraSpecialArgs = moduleArgs;

        users.${user} = {
          personal.enable = true;

          imports = [
            inputs.sops-nix.homeManagerModules.sops
            inputs.nix-index-database.homeModules.nix-index
          ];
        };
      };
    }
  ];
}
