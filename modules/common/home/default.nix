{ lib, ... }: {
  imports = [
    ../../../overlay

    ./archive.nix
    ./atuin.nix
    ./bat.nix
    ./bottom.nix
    ./chromium.nix
    ./db.nix
    ./direnv.nix
    ./docker.nix
    ./email.nix
    ./firefox.nix
    ./fonts.nix
    ./git.nix
    ./gocryptfs.nix
    ./gpg.nix
    ./gtk.nix
    ./helix.nix
    ./k8s.nix
    ./kitty.nix
    ./mpv.nix
    ./nixgl.nix
    ./nix-index.nix
    ./packages.nix
    ./parcel.nix
    ./ripgrep.nix
    ./swappy.nix
    ./syncthing.nix
    ./thunderbird.nix
    ./tig.nix
    ./vimiv.nix
    ./vscode.nix
    ./w3m.nix
    ./zsh.nix
  ];

  # See here what bumping this value impacts: https://nix-community.github.io/home-manager/release-notes.xhtml
  config.home.stateVersion = "26.05";

  options = {
    user = lib.mkOption {
      type = lib.types.str;
      description = "Primary user of the system";
    };

    personal.enable = lib.mkEnableOption "Personal setup";
  };
}
