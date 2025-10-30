{ config, pkgs, ... }: {
  home-manager.users.${config.user}.home.packages = with pkgs; [
    (python3.withPackages (ps: with ps; [
      pyyaml
      # pynacl
      # pylint
      # tldextract
      # isort
      # black
      # pip
    ]))

    azure-cli
    bash
    bat
    coreutils
    curl
    diffutils
    # flameshot
    gawk
    gh
    gnugrep
    gnum4
    gnumake
    gnused
    gnutar
    gnutls
    just
    pinentry_mac
    # gopls
    # gzip
    kubelogin
    kubernetes-helm
    kubectl
    kubectx
    # less
    # nodePackages.prettier
    # openssh
    # sshpass
    # patch
    # rust-analyzer
    # shellcheck
    #terraform
    # unixtools.watch
    #vault
    # wget
    # wireguard-go
    # which
    # yq
    # zstd


    bfs
    dfrs
    doggo
    dos2unix
    dua
    editorconfig-core-c
    eza
    fd
    file
    fzf
    gcc
    git
    glib
    go
    jq
    magic-wormhole-rs
    maximbaz-scripts
    pass
    perlPackages.vidir
    pigz
    postgresql_16
    progress
    pwgen
    qrencode
    rsync
    sipcalc
    socat
    sqlite
    teehee
    tig
    tree
    unrar
    unzip
    vivid
    w3m
    wireguard-tools
    yt-dlp
    zip
    zsh
    sops
  ];
}
