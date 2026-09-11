#!/usr/bin/env sh

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: this script must be run as root (for example, with sudo)." >&2
  exit 1
fi

tee /etc/apparmor.d/nix-store-bwrap >/dev/null <<'EOF'
abi <abi/4.0>,
include <tunables/global>

profile nix-store-bwrap /nix/store/*-bubblewrap-*/bin/bwrap flags=(unconfined) {
 userns,
}
EOF

apparmor_parser --skip-kernel-load /etc/apparmor.d/nix-store-bwrap

apparmor_parser --replace /etc/apparmor.d/nix-store-bwrap
