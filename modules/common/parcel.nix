{ config, pkgs, ... }: {
  home-manager.users.${config.user} = {
    programs.firefox.nativeMessagingHosts = [ pkgs.parcel-host ];
    programs.chromium.nativeMessagingHosts = [ pkgs.parcel-host ];
  };
}
