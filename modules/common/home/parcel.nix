{ pkgs, ... }: {
  programs.firefox.nativeMessagingHosts = [ pkgs.parcel-host ];
  programs.chromium.nativeMessagingHosts = [ pkgs.parcel-host ];
}
