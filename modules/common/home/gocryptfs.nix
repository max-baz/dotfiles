{ config, lib, pkgs, osConfig, ... }: {
  home.packages = [
    pkgs.gocryptfs
  ];

  systemd.user.tmpfiles.rules = lib.mkIf (pkgs.stdenv.isLinux && (osConfig != null)) [
    "d /home/${config.home.username}/decrypted 0700 ${config.home.username} users -"
  ];
}
