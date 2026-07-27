{ pkgs, ... }: {
  home.packages = with pkgs; [
    cargo
    cargo-outdated
    curlie
    dfrs
    doggo
    dos2unix
    dua
    earlyoom
    editorconfig-core-c
    eza
    fd
    ffmpeg
    file
    fzf
    gcc
    git
    github-cli
    glib
    gnumake
    go
    inotify-tools
    # iptables-nftables-compat
    jq
    just
    libnotify
    magic-wormhole-rs
    maximbaz-scripts
    netcat-openbsd
    # nftables
    nodejs
    nono
    # pam_u2f
    pass
    perlPackages.vidir
    pi-coding-agent
    pik
    # playerctl

    prettier
    progress
    # pulseaudio
    # push2talk
    pwgen
    python3
    # qalculate-gtk
    qrencode
    rsync
    # signal-desktop
    # sipcalc
    # sleek-todo
    # slurp
    socat
    sops
    spicedb-zed
    sqlite
    # swappy
    # swaybg
    # swaylock
    # swayr
    syncthing
    # systembus-notify
    # tailspin
    teehee
    tig
    todo-txt-cli
    # trash-cli
    tree
    # udiskie
    # unstable-small.ttl
    # usbguard
    # vault-bin
    # vimiv-qt
    vivid
    # waysip
    # wev
    # wf-recorder
    # whisper-cpp-vulkan
    wireguard-tools
    wl-clipboard
    yarn
    yazi
    yq-go
    yubikey-manager
    # zathura
  ];
}
