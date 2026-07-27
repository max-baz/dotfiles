{ config, lib, ... }: {
  imports = [
    ../../../overlay

    ./base-packages.nix
    ./nix.nix
    ./tailscale.nix
    ./timezone.nix
    ./upgrade-diff.nix
    ./zsh.nix
  ];

  config.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${config.user}.imports = [ ../home ];
  };

  options = {
    user = lib.mkOption {
      type = lib.types.str;
      description = "Primary user of the system";
    };
  };

  # # TODO
  # config.home-manager.users.${config.user}.home.sessionVariables = {
  #   # QT_QPA_PLATFORM = "wayland-egl";
  #   # QT_STYLE_OVERRIDE = "Adwaita-dark";

  #   # CARGO_HOME = "${config.xdg.stateHome}/cargo";
  #   # GOPATH = "${config.xdg.stateHome}/go";
  #   # npm_config_cache = "${config.xdg.cacheHome}/npm";
  #   # LESSHISTFILE = "-";
  # };
}
