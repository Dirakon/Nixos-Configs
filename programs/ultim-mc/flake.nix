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
      ultim-mc-outputs =
        flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            hash = "sha256-sF38xXGXdoKTbUIwYNnpulVF0Zn0yHWSk1DSz5n3cLQ=";

            ultim-mc-original = pkgs.fetchurl {
              url = "https://nightly.link/UltimMC/Launcher/workflows/main/develop/mmc-cracked-lin64.zip"; # TODO: use source code (as flake input?) instead for good versioning
              hash = "${hash}";
            };
          in
          let
            qt-app-builder = { stdenv, lib, qtbase, wrapQtAppsHook }:
              let
                buildInputs = [
                  qtbase
                ];
                ultim-mc-unwrapped = pkgs.stdenv.mkDerivation {
                  pname = "ultimMC";
                  version = "0.1";

                  src = ultim-mc-original;
                  nativeBuildInputs = with pkgs; [
                    autoPatchelfHook
                    unzip
                    wrapQtAppsHook
                  ];
                  buildInputs = buildInputs;
                  runtimeDependencies = with pkgs; [
                  ];

                  unpackPhase = ''
                    mkdir source
                    unzip $src -d source
                  '';

                  installPhase = ''
                    mkdir -p $out/bin
                    cp -r source/UltimMC/bin $out/
                    chmod +x $out/bin/UltimMC
                  '';
                };

                ultim-mc-wrapped = pkgs.buildFHSEnv {
                  name = "ultim-mc";
                  targetPkgs = pkgs: buildInputs ++ [ ultim-mc-unwrapped ];
                  runScript = "UltimMC -d ~/.local/state/ultim-mc";
                };
              in
              ultim-mc-wrapped;
          in
          # https://nixos.wiki/wiki/Qt
          let ultim-mc-app = pkgs.libsForQt5.callPackage qt-app-builder { };
          in
          {
            ultim-mc = ultim-mc-app;
            devShell = pkgs.mkShell {
              buildInputs = [
                ultim-mc-app
                # pkgs.jdk
                # pkgs.libsForQt5.qt5.qtwayland
              ];
            };
          });
    in
    let
      formatter-outputs =
        flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            formatter = pkgs.nixpkgs-fmt;
          });
    in
    ultim-mc-outputs // formatter-outputs;
}
