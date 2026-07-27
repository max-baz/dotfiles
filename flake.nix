{
  description = "maxbaz";

  # # uncomment during installation
  # nixConfig = {
  #   extra-substituters = [
  #     "https://cache.soopy.moe"
  #     "https://nixos-apple-silicon.cachix.org"
  #   ];
  #   extra-trusted-public-keys = [
  #     "cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo="
  #     "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
  #   ];
  # };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stable.url = "github:nixos/nixpkgs/nixos-25.11";
    unstable-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixgl.url = "github:nix-community/nixGL";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-hardware.url = "github:cooparo/nixos-hardware/dell-xps-14-da14260";

    apple-silicon-support.url = "github:nix-community/nixos-apple-silicon";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-darwin = {
      url = "github:bandithedoge/nixpkgs-firefox-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles-private.url = "git+file:///home/max/.dotfiles-private";

    waysip = {
      url = "github:waycrate/waysip";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      nixpkgsConfig = {
        allowUnfree = true;
        input-fonts.acceptLicense = true;
        joypixels.acceptLicense = true;
      };
      mkModuleArgs = system: {
        nixgl = inputs.nixgl;
        stable = import inputs.stable { inherit system; config = nixpkgsConfig; };
        unstable-small = import inputs.unstable-small { inherit system; config = nixpkgsConfig; };
        util = import ./util;
        firefox-addons = inputs.firefox-addons.packages.${system};
        waysip = inputs.waysip.packages.${system}.default;
      };
      hostArgs = { inherit inputs nixpkgsConfig mkModuleArgs; };
    in
    rec {
      nixosConfigurations = {
        home-pika = import ./hosts/home-pika hostArgs;
      };

      darwinConfigurations = { };

      homeConfigurations = {
        home-pika = nixosConfigurations.home-pika.config.home-manager.users.${nixosConfigurations.home-pika.config.user}.home;
        work-xps14 = import ./hosts/work-xps14 hostArgs;
      };
    };
}
