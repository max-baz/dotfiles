{
  ### SETUP
  # sudo systemd-cryptenroll --fido2-device=auto /dev/sda1
  environment.etc.crypttab.text = ''
    backup_sandisk  LABEL=backup_sandisk    none    noauto,fido2-device=auto
    backup_wd       LABEL=backup_wd         none    noauto,fido2-device=auto
  '';
}
