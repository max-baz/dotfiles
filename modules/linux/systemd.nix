{ pkgs, ... }: {
  systemd.settings.Manager.DefaultTimeoutStopSec = 10;
  services.journald.settings.Journal.SystemMaxUse = "300M";
  services.dbus.packages = [ pkgs.gcr_3 ];
}
