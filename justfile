default: switch

[linux]
switch *flags: git-add
    sudo nixos-rebuild switch --flake $HOME/.dotfiles --impure {{flags}}

[macos]
switch *flags: git-add
    nix run -- nix-darwin switch --flake $HOME/.dotfiles {{flags}}

trace: (switch "--show-trace")
    
home: git-add
    nix run -- home-manager switch --flake $HOME/.dotfiles#$(hostname)

update: git-commit-flakes git-add
    nix flake update --option access-tokens "github.com=$(gh auth token)"

update-private: git-add
    nix flake update dotfiles-private

git-commit-flakes:
    #!/usr/bin/env sh
    if git -C $HOME/.dotfiles status --porcelain -- flake.lock | grep -q .; then
       git -C $HOME/.dotfiles add flake.lock
       git -C $HOME/.dotfiles commit -m "update flakes"
    fi

git-add:
    git -C $HOME/.dotfiles add --intent-to-add --all
    git -C $HOME/.dotfiles-private add --intent-to-add --all
