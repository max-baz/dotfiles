{
  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  networking = {
    useDHCP = false;

    wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = true;
      settings.General.AddressRandomization = "network";
      settings.General.AddressRandomizationRange = "full";
    };

    nftables.enable = true;
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [
        22000 # syncthing
      ];
      allowedUDPPorts = [
        22000 # syncthing
        21027 # syncthing discovery
      ];
    };
  };

  systemd.network = {
    enable = true;
    wait-online.enable = false;
    networks = {
      "20-wireless" = {
        matchConfig.Name = "wlan0";
        networkConfig.DHCP = "yes";
        dhcpV4Config.RouteMetric = 20;
      };
      "50-wired" = {
        matchConfig.Name = "enp*";
        networkConfig.DHCP = "yes";
        dhcpV4Config.RouteMetric = 10;
      };
    };
  };

  # https://gitlab.archlinux.org/archlinux/rfcs/-/merge_requests/51
  boot.kernel.sysctl."net.ipv4.tcp_keepalive_time" = 120;
}
