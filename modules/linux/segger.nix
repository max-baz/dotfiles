{ config, pkgs, ... }: {
  nixpkgs = {
    config = {
      allowUnfree = true;
      segger-jlink.acceptLicense = true;
      permittedInsecurePackages = [ "segger-jlink-qt4-874" ];
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="1366", ATTR{idProduct}=="0101", MODE="0666", GROUP="segger"
  '';
  users.groups.segger = { };
  users.users.${config.user}.extraGroups = [ "segger" ];

  home-manager.users.${config.user}.home.packages = with pkgs; [
    segger-jlink
    nrf-command-line-tools
  ];
}
