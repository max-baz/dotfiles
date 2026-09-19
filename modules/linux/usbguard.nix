{
  services.usbguard = {
    presentControllerPolicy = "apply-policy";
    IPCAllowedGroups = [ "wheel" ];
    dbus.enable = true;
  };
}
