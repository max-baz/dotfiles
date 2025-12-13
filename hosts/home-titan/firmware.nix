{ pkgs, ... }:
let
  src = pkgs.fetchzip {
    url = "https://max.baz.nu/home-titan-firmware.tar.gz";
    hash = "sha256-1974c+poAvC1QqKLRN5rIzINtM7rvXG7ug9qH92wyyk=";
  };
in
{
  hardware.firmware = [
    (pkgs.stdenvNoCC.mkDerivation {
      name = "brcm-firmware";
      src = src;
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/lib/firmware/brcm
        cp -r $src/* $out/lib/firmware/brcm/
      '';
    })
  ];
}
