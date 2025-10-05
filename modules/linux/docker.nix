{ config, pkgs, ... }: {
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

  virtualisation = {
    oci-containers.backend = "podman";
    containers.storage.settings.storage.driver = "btrfs";
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  systemd.user.services.podman-restart.wantedBy = [ "default.target" ];

  home-manager.users.${config.user}.home.packages = [ pkgs.podman-compose ];
}
