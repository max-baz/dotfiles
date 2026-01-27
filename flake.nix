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
    stable.url = "github:nixos/nixpkgs/nixos-25.05";
    unstable-small.url = "github:nixos/nixpkgs/nixos-unstable-small";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
    };

    apple-silicon-support = {
      url = "github:nix-community/nixos-apple-silicon";
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
    let globals = { user = "max"; }; in rec {
      nixosConfigurations = {
        home-titan = import ./hosts/home-titan { inherit inputs globals; };
      };

      darwinConfigurations = { };

      homeConfigurations = {
        home-titan = nixosConfigurations.home-titan.config.home-manager.users.${globals.user}.home;
      };
    };
}
