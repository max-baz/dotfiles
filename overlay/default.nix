{ config, pkgs, ... }: {
  nixpkgs.overlays = [
    (final: prev: {
      input-fonts = prev.input-fonts.overrideAttrs (_old: {
        src = prev.fetchzip {
          # This URL is too long for fetchzip, and returns non-reproducible zips with new sha256 every time ☹️
          # url = "https://input.djr.com/build/?customize&fontSelection=fourStyleFamily&regular=InputMonoNarrow-Regular&italic=InputMonoNarrow-Italic&bold=InputMonoNarrow-Bold&boldItalic=InputMonoNarrow-BoldItalic&a=0&g=0&i=serifs_round&l=serifs_round&zero=slash&asterisk=height&braces=0&preset=default&line-height=1.1&accept=I+do&email=";
          url = "https://max.baz.nu/share/input-fonts.zip";
          sha256 = "09qfb3h2s1dlf6kn8d4f5an6jhfpihn02zl02sjj26zgclrp6blc";
          stripRoot = false;
        };
      });

      wldash = prev.wldash.override (old: {
        rustPlatform = old.rustPlatform // {
          buildRustPackage = args: old.rustPlatform.buildRustPackage (args // {
            src = prev.fetchFromGitHub {
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

      wluma = prev.wluma.overrideAttrs (old: rec {
        version = "5.0.0";
        src = prev.fetchFromGitHub {
          owner = "max-baz";
          repo = "wluma";
          rev = version;
          hash = "sha256-MN5KxodnQPMwKZzvpA+zLnsp+uX6h2OtS7cduRR6fp8=";
        };
        cargoDeps = prev.rustPlatform.fetchCargoVendor {
          inherit src;
          hash = "sha256-9TEC2+GcPXWfGTU/KTu6LSGbjAkWchPRBalmOkg9PI4=";
        };
        buildInputs = old.buildInputs ++ [ prev.pipewire ];
      });

      joypixels = prev.joypixels.overrideAttrs (_old: {
        version = "11.0.0";
        src = prev.fetchurl {
          name = "joypixels-android.ttf";
          url = "https://max.baz.nu/share/joypixels-emoji.ttf";
          hash = "sha256-taHKy2rin1SE24BKnB8LZ662U8MO9HL5if3+mHQ38Io=";
        };
      });

      pik = prev.rustPlatform.buildRustPackage rec {
        pname = "pik";
        version = "0.9.0";
        src = prev.fetchFromGitHub {
          owner = "jacek-kurlit";
          repo = pname;
          rev = version;
          hash = "sha256-YAnMSVQu/E+OyhHX3vugfBocyi++aGwG9vF6zL8T2RU=";
        };
        cargoHash = "sha256-vXE9AL0+WCPhwJTqglwOhIeqhI+JQB3Cr8GBQjmW+zc=";
      };

      spicedb-zed = prev.symlinkJoin {
        name = "spicedb-zed";
        paths = [ prev.spicedb-zed ];
        buildInputs = [ prev.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/zed \
            --set PASSWORD_STORE_DIR /home/${config.user}/.password-store-local
        '';
      };

      waybar-syncthing = prev.stdenv.mkDerivation rec {
        pname = "waybar-syncthing";
        version = "1.2.0";

        src =
          let
            system = prev.stdenv.hostPlatform.system;
            hashes = {
              aarch64-linux = "sha256-YJIDL+dfQbmgbgCXBOK6+3SZCgNn43ZapQVuiobqkuk=";
              x86_64-linux = "sha256-cdC0Xg5guA9bMCWyo8sml/xoR43wZ9EKLsbF9qL3OR8=";
            };
          in
          prev.fetchurl {
            url = "https://github.com/max-baz/${pname}/releases/download/${version}/${pname}-${system}-musl";
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

      push2talk = prev.stdenv.mkDerivation rec {
        pname = "push2talk";
        version = "1.3.3";

        src =
          let
            system = prev.stdenv.hostPlatform.system;
            hashes = {
              aarch64-linux = "sha256-Z3FtkpVVzDjNie8fY805F1j1f9GtFgngFxOWt6er68E=";
              x86_64-linux = "sha256-9VzLyZ/1FI5yAMTbQkCl6yZBygkcCLKwZ4IFvnejjG8=";
            };
          in
          prev.fetchurl {
            url = "https://github.com/cyrinux/${pname}/releases/download/${version}/${pname}-${system}";
            hash = hashes.${system} or (throw "push2talk: unsupported system ${system}");
          };

        dontUnpack = true;
        nativeBuildInputs = [ prev.autoPatchelfHook ];
        buildInputs = with prev; [
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

      network-dmenu = prev.stdenv.mkDerivation rec {
        pname = "network-dmenu";
        version = "2.13.2";

        src =
          let
            system = prev.stdenv.hostPlatform.system;
            hashes = {
              aarch64-linux = "sha256-Og2Z8LiNqkNJy+AODHkDrHSdowaPSuOWeT6ZjF1S4xs=";
              x86_64-linux = "sha256-WKu+N+bS1hQz8gCkd5MiD5RwB1GwsoZD67T1K0KvuNI=";
            };
          in
          prev.fetchurl {
            url = "https://github.com/cyrinux/${pname}/releases/download/${version}/${pname}-${system}";
            hash = hashes.${system} or (throw "network-dmenu: unsupported system ${system}");
          };

        dontUnpack = true;
        nativeBuildInputs = [ prev.autoPatchelfHook ];
        buildInputs = with prev; [
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

      parcel-host = prev.stdenv.mkDerivation rec {
        pname = "parcel-host";
        version = "1.0.2";

        src = prev.fetchFromGitHub {
          owner = "parcel-pm";
          repo = "parcel";
          rev = "v${version}";
          hash = "sha256-UlF0avdoX7/Msx66nNuLPOCRSNE5PXRF4ELBYYtcFIU=";
        };

        dontBuild = true;

        nativeBuildInputs = [ pkgs.makeWrapper ];

        installPhase = ''
          runHook preInstall

          install -Dm755 parcel-host $out/bin/parcel-host
          install -Dm755 src/parcel-host $out/share/parcel-host/main-host.sh

          wrapProgram $out/bin/parcel-host \
            --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.bash pkgs.gnupg pkgs.jq pkgs.coreutils ]}

          mkdir -p $out/lib/mozilla/native-messaging-hosts
          cat > $out/lib/mozilla/native-messaging-hosts/com.github.erayd.parcel.json <<EOF
          {
            "name": "com.github.erayd.parcel",
            "description": "Native host component for the Parcel extension",
            "path": "$out/bin/parcel-host",
            "type": "stdio",
            "allowed_extensions": [ "parcel@erayd.net" ]
          }
          EOF

          mkdir -p $out/etc/chromium/native-messaging-hosts
          cat > $out/etc/chromium/native-messaging-hosts/com.github.erayd.parcel.json <<EOF
          {
            "name": "com.github.erayd.parcel",
            "description": "Native host component for the Parcel extension",
            "path": "$out/bin/parcel-host",
            "type": "stdio",
            "allowed_origins": [ "chrome-extension://iondhmpkblldcbiloajfkonllgkljbgj/", "chrome-extension://ciifpadakeohfnnneflckhojbldkkllp/" ]
          }
          EOF

          runHook postInstall
        '';

        meta = {
          description = "Native messaging host for the Parcel browser extension";
          homepage = "https://github.com/parcel-pm/parcel";
          platforms = [ "aarch64-linux" "x86_64-linux" ];
          mainProgram = "parcel-host";
        };
      };

      nono = prev.stdenv.mkDerivation rec {
        pname = "nono";
        version = "0.69.0";
        src = prev.fetchurl {
          url = "https://github.com/nolabs-ai/nono/releases/download/v${version}/nono-v${version}-x86_64-unknown-linux-gnu.tar.gz";
          hash = "sha256-PHn7DcKpFxt9RBAmllZm9WUsQvZ7xXEKJ9jp+Sgi9hk=";
        };
        dontUnpack = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          tar xzf $src -C $out/bin
          chmod +x $out/bin/nono
          runHook postInstall
        '';
        meta = with prev.lib; {
          description = "Sandbox any AI agent in seconds - zero setup, zero latency";
          homepage = "https://nono.sh";
          license = licenses.asl20;
          platforms = [ "x86_64-linux" ];
          mainProgram = "nono";
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
