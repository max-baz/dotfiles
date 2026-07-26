{ config, pkgs, lib, ... }: {
  home-manager.users.${config.user}.home.packages = with pkgs; [
    sbctl
    openssl
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
}
