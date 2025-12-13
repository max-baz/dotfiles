#!/usr/bin/env zsh

source /etc/profiles/per-user/max/etc/profile.d/hm-session-vars.sh

[[ "$TTY" == /dev/tty* ]] || return 0

export GPG_TTY="$TTY"
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
if [[ "$(uname)" == "Darwin" ]]; then
    launchctl setenv GPG_TTY "$GPG_TTY"
    launchctl setenv SSH_AUTH_SOCK "$SSH_AUTH_SOCK"
fi


if [[ -z $DISPLAY && "$TTY" == "/dev/tty1" ]]; then
    systemd-cat -t sway sway
    systemctl --user stop graphical-session.target
    systemctl --user unset-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK I3SOCK
fi
