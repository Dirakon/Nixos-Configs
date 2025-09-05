{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; # "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { self
    , nixpkgs
    , flake-utils
    ,
    }:
    let
      lmms-outputs = flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          lmms = pkgs.stdenv.mkDerivation {
            pname = "lmms";
            version = "0-unstable-2025-01-28";

            src = pkgs.fetchFromGitHub {
              owner = "LMMS";
              repo = "lmms";
              rev = "dec6a045746f5cc3ba831f2521cbcd95a7e314de";
              sha256 = "sha256-rvauyjXOXTLirImUqvvVARlnUUXGzCT1vj52+5+OZVY=";
              fetchSubmodules = true;
            };

            nativeBuildInputs = with pkgs; [
              cmake
              libsForQt5.qt5.qttools
              pkg-config
              qt5.wrapQtAppsHook
            ];

            buildInputs = with pkgs; [
              fftwFloat
              libsForQt5.qt5.qtbase
              libsForQt5.qt5.qtx11extras
              libsamplerate
              libsndfile
              SDL2
              alsa-lib
              carla
              fltk
              fluidsynth
              glibc_multi
              lame
              libgig
              libjack2
              libogg
              libpulseaudio
              libsoundio
              libvorbis
              lilv
              lv2
              perl540
              perl540Packages.ListMoreUtils
              perl540Packages.XMLParser
              portaudio
              sndio
              suil
              wineWowPackages.minimal
            ];

            patches = [
              (pkgs.substitute {
                src = ./patch.patch;
                substitutions = [
                  "--replace-fail"
                  "@WINE_LOCATION@"
                  pkgs.wineWowPackages.minimal
                ];
              })
            ];

            cmakeFlags = [
              "-DWANT_WEAKJACK=OFF"
            ];
          };
        in
        {
          lmms = lmms;
          devShell = pkgs.mkShell {
            buildInputs = [
              lmms
            ];
          };
        }
      );
    in
    let
      formatter-outputs = flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {

          formatter = pkgs.nixpkgs-fmt;
        }
      );
    in
    lmms-outputs // formatter-outputs;
}
