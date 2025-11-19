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
  system = "aarch64-linux";
  specialArgs = {
    util = (import ../../util);
    firefox-addons = inputs.firefox-addons.packages.${system};
    waysip = inputs.waysip.packages.${system}.default;
  };
  modules = [
    globals
    stable
    unstable-small
    inputs.sops-nix.nixosModules.sops
    inputs.apple-silicon-support.nixosModules.apple-silicon-support
    inputs.maximbaz-private.nixosModules.linux
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../../modules/linux
    # Workaround for Mesa 25.3.0 regression
    # https://github.com/nix-community/nixos-apple-silicon/issues/380
    ({ pkgs, ... }: {
      hardware.graphics.package =
        assert pkgs.mesa.version == "25.3.0";
        (import
          (fetchTarball {
            url = "https://github.com/NixOS/nixpkgs/archive/c5ae371f1a6a7fd27823bc500d9390b38c05fa55.tar.gz";
            sha256 = "sha256-4PqRErxfe+2toFJFgcRKZ0UI9NSIOJa+7RXVtBhy4KE=";
          })
          { localSystem = pkgs.stdenv.hostPlatform; }).mesa;
    })
    {
      personal.enable = true;

      networking.hostName = "home-manitoba";

      boot = {
        loader = {
          efi.canTouchEfiVariables = false;
          systemd-boot = {
            enable = true;
            configurationLimit = 10;
          };
        };
        extraModprobeConfig = ''
          options hid_apple swap_opt_cmd=1 swap_fn_leftctrl=1 iso_layout=1
        '';
        initrd.systemd.enable = true;
      };

      home-manager.users.${globals.user}.imports = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.nix-index-database.homeModules.nix-index
      ];
    }
  ];
}
