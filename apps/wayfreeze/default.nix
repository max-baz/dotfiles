{ lib, rustPlatform, makeWrapper, bash, grim, slurp, sway }:
rustPlatform.buildRustPackage {
  pname = "wayfreeze";
  version = "0.1.0";
  src = lib.cleanSourceWith {
    src = ./.;
    filter = path: type: builtins.baseNameOf path != "target" && lib.cleanSourceFilter path type;
  };
  cargoLock.lockFile = ./Cargo.lock;
  nativeBuildInputs = [ makeWrapper ];
  postFixup = ''
    wrapProgram $out/bin/wayfreeze \
      --prefix PATH : ${lib.makeBinPath [ bash grim slurp sway ]}
  '';
  meta = {
    description = "Frozen region screenshots with HDR-to-SDR capture for Sway";
    license = lib.licenses.isc;
    platforms = lib.platforms.linux;
    mainProgram = "wayfreeze";
  };
}
