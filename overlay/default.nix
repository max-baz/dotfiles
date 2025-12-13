{ config, pkgs, ... }: {
  nixpkgs.overlays = [
    (self: super: {
      input-fonts = super.input-fonts.overrideAttrs (_old: {
        src = super.fetchzip {
          # This URL is too long for fetchzip, and returns non-reproducible zips with new sha256 every time ☹️
          # url = "https://input.djr.com/build/?customize&fontSelection=fourStyleFamily&regular=InputMonoNarrow-Regular&italic=InputMonoNarrow-Italic&bold=InputMonoNarrow-Bold&boldItalic=InputMonoNarrow-BoldItalic&a=0&g=0&i=serifs_round&l=serifs_round&zero=slash&asterisk=height&braces=0&preset=default&line-height=1.1&accept=I+do&email=";
          url = "https://max.baz.nu/input-fonts.zip";
          sha256 = "09qfb3h2s1dlf6kn8d4f5an6jhfpihn02zl02sjj26zgclrp6blc";
          stripRoot = false;
        };
      });

      wldash = super.wldash.override (old: {
        rustPlatform = old.rustPlatform // {
          buildRustPackage = args: old.rustPlatform.buildRustPackage (args // {
            src = super.fetchFromGitHub {
              owner = "cyrinux";
              repo = "wldash";
              rev = "9cc29f2507a746ef6359dd081d9f2fe2f43c2a23";
              hash = "sha256-aATJIHETQDX1UXkn5/1jVESgdQFbTFySYuL01NvP54s=";
            };
            cargoHash = "sha256-xuyUKKAIGEJwl9mcNQLFhk5r6+YSl+0EkUHPk//gM9c=";
            cargoPatches = [ ];
          });
        };
      });

      joypixels = super.joypixels.overrideAttrs (_old: {
        version = "10.0.0";
        src = super.fetchurl {
          name = "joypixels-android.ttf";
          url = "https://max.baz.nu/joypixels-emoji.ttf";
          hash = "sha256-T4vBPTdXDxnD72n+XKeGeyKomVG22UTRlOymobzqHv4=";
        };
      });

      pik = super.rustPlatform.buildRustPackage rec {
        pname = "pik";
        version = "0.9.0";
        src = super.fetchFromGitHub {
          owner = "jacek-kurlit";
          repo = pname;
          rev = version;
          hash = "sha256-YAnMSVQu/E+OyhHX3vugfBocyi++aGwG9vF6zL8T2RU=";
        };
        cargoHash = "sha256-vXE9AL0+WCPhwJTqglwOhIeqhI+JQB3Cr8GBQjmW+zc=";
      };

      spicedb-zed = super.symlinkJoin {
        name = "spicedb-zed";
        paths = [ super.spicedb-zed ];
        buildInputs = [ super.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/zed \
            --set PASSWORD_STORE_DIR /home/${config.user}/.password-store-local
        '';
      };

      waybar-syncthing = super.stdenv.mkDerivation rec {
        pname = "waybar-syncthing";
        version = "1.0.0";

        src =
          let
            system = super.stdenv.hostPlatform.system;
            hashes = {
              aarch64-linux = "sha256-YJIDL+dfQbmgbgCXBOK6+3SZCgNn43ZapQVuiobqkuk=";
              x86_64-linux = "sha256-76wRXqfryMgXGA+7W50052HJUS2u9F3BaQvIlQY3RIg=";
            };
          in
          super.fetchurl {
            url = "https://github.com/maximbaz/${pname}/releases/download/${version}/${pname}-${system}-musl";
            hash = hashes.${system} or (throw "waybar-syncthing: unsupported system ${system}");
          };

        dontUnpack = true;
        installPhase = ''
          mkdir -p $out/bin
          install -Dm755 "$src" "$out/bin/${pname}"
        '';

        meta = {
          platforms = [ "aarch64-linux" "x86_64-linux" ];
          mainProgram = pname;
        };
      };

      push2talk = super.stdenv.mkDerivation rec {
        pname = "push2talk";
        version = "1.3.3";

        src =
          let
            system = super.stdenv.hostPlatform.system;
            hashes = {
              aarch64-linux = "sha256-Z3FtkpVVzDjNie8fY805F1j1f9GtFgngFxOWt6er68E=";
              x86_64-linux = "sha256-9VzLyZ/1FI5yAMTbQkCl6yZBygkcCLKwZ4IFvnejjG8=";
            };
          in
          super.fetchurl {
            url = "https://github.com/cyrinux/${pname}/releases/download/${version}/${pname}-${system}";
            hash = hashes.${system} or (throw "push2talk: unsupported system ${system}");
          };

        dontUnpack = true;
        nativeBuildInputs = [ super.autoPatchelfHook ];
        buildInputs = with super; [
          stdenv.cc.cc.lib
          libxkbcommon
          libinput
          libpulseaudio
          systemd
        ];

        installPhase = ''
          mkdir -p $out/bin
          install -Dm755 "$src" "$out/bin/${pname}"
        '';

        meta = {
          platforms = [ "aarch64-linux" "x86_64-linux" ];
          mainProgram = pname;
        };
      };

      network-dmenu = super.stdenv.mkDerivation rec {
        pname = "network-dmenu";
        version = "2.13.2";

        src =
          let
            system = super.stdenv.hostPlatform.system;
            hashes = {
              aarch64-linux = "sha256-Og2Z8LiNqkNJy+AODHkDrHSdowaPSuOWeT6ZjF1S4xs=";
              x86_64-linux = "sha256-WKu+N+bS1hQz8gCkd5MiD5RwB1GwsoZD67T1K0KvuNI=";
            };
          in
          super.fetchurl {
            url = "https://github.com/cyrinux/${pname}/releases/download/${version}/${pname}-${system}";
            hash = hashes.${system} or (throw "network-dmenu: unsupported system ${system}");
          };

        dontUnpack = true;
        nativeBuildInputs = [ super.autoPatchelfHook ];
        buildInputs = with super; [
          stdenv.cc.cc.lib
          dbus
        ];

        installPhase = ''
          mkdir -p $out/bin
          install -Dm755 "$src" "$out/bin/${pname}"
        '';

        meta = {
          platforms = [ "aarch64-linux" "x86_64-linux" ];
          mainProgram = pname;
        };
      };

      jail-ai = super.stdenv.mkDerivation rec {
        pname = "jail-ai";
        version = "0.45.8";

        src =
          let
            system = super.stdenv.hostPlatform.system;
            hashes = {
              aarch64-linux = "sha256-s/dSDRVyMQJDOv+i1Q6YgnXc3Z4M/LzG4up9C2VnzkI=";
              x86_64-linux = "sha256-3MjxZKFfbC7jBFPp5jImbB0cQJLn94TjV6mOMujERQs=";
            };
          in
          super.fetchurl {
            url = "https://github.com/cyrinux/${pname}/releases/download/v${version}/${pname}-${system}";
            hash = hashes.${system} or (throw "jail-ai: unsupported system ${system}");
          };

        src_ebpf_loader =
          let
            system = super.stdenv.hostPlatform.system;
            hashes = {
              aarch64-linux = "sha256-f2z9+VesRDqaxkMHwP0vBwNY8xc1h0Q7JP3e+TSigI8=";
              x86_64-linux = "sha256-dDLsTs6WfHciZxXGz1VzHBzWBOiOS6a6vZ0i7R7mDm4=";
            };
          in
          super.fetchurl {
            url = "https://github.com/cyrinux/${pname}/releases/download/v${version}/${pname}-ebpf-loader-${system}";
            hash = hashes.${system} or (throw "jail-ai-ebpf-loader: unsupported system ${system}");
          };

        dontUnpack = true;
        dontStrip = true;

        installPhase = ''
          mkdir -p $out/bin
          install -Dm755 "$src" "$out/bin/${pname}"
          install -Dm755 "$src_ebpf_loader" "$out/bin/${pname}-ebpf-loader"
        '';

        meta = {
          platforms = [ "aarch64-linux" "x86_64-linux" ];
          mainProgram = pname;
        };
      };

      maximbaz-scripts = pkgs.stdenv.mkDerivation {
        pname = "maximbaz-scripts";
        version = "1.0.0";
        src = ./bin;
        dontUnpack = true;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        installPhase = ''
          install -Dm755 $src/* -t $out/bin/
          install -Dm755 $src/dmenu $out/bin/dmenu-wl
        '';
        postFixup = ''
          for script in $out/bin/*; do 
            wrapProgram $script \
              --suffix PATH : /run/wrappers/bin/ \
              --suffix PATH : /etc/profiles/per-user/max/bin/ \
              --suffix PATH : /run/current-system/sw/bin/ \
              ;
          done
        '';
      };
    })
  ];
}
