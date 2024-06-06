{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; # "github:NixOS/nixpkgs/nixpkgs-unstable";
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
            hash = "sha256-Yq1WEtR5D4c7lnTAFS1lmI0wtCZm7rVkb1/ffHKwnj8=";

            ultim-mc-original = pkgs.fetchurl {
              url = "https://nightly.link/UltimMC/Launcher/workflows/main/develop/mmc-cracked-lin64.zip"; # TODO: use source code (as flake input?) instead for good versioning
              hash = "${hash}";
            };

            buildInputs = with pkgs; [
              alsa-lib
              dbus
              fontconfig
              libGL
              libpulseaudio
              libxkbcommon
              makeWrapper
              mesa
              patchelf
              speechd
              udev
              vulkan-loader
              xorg.libX11
              xorg.libXcursor
              xorg.libXinerama
              xorg.libXrandr
              xorg.libXrender
              dbus
              fontconfig
              xorg.libICE
              xorg.libSM
              portaudio
              lttng-ust
              jdk

              libsForQt5.qt5.qtscxml
            ];



            ultim-mc-unwrapped = pkgs.stdenv.mkDerivation {
              pname = "ultimMC";
              version = "0.1";

              src = ultim-mc-original;
              nativeBuildInputs = with pkgs; [ autoPatchelfHook unzip ];
              buildInputs = buildInputs;


              runtimeDependencies = with pkgs; [
                libGL
                xorg.libX11
                xorg.libXcursor
                xorg.libXinerama
                xorg.libXext
                xorg.libXrandr
                xorg.libXrender
                xorg.libXi
                xorg.libXfixes
                libxkbcommon
                alsa-lib
                wayland
                dbus
                fontconfig
                xorg.libICE
                xorg.libSM
                portaudio
                lttng-ust
                jdk

                libsForQt5.qt5.qtscxml
              ];

              dontAutoPatchelf = false;
              dontWrapQtApps = true;

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

            ultim-mc-wrapped = pkgs.buildFHSUserEnv {
              name = "ultim-mc";
              targetPkgs = pkgs: buildInputs ++ [ ultim-mc-unwrapped ];
              runScript = "UltimMC -d ~/.local/state/ultim-mc";
            };
          in
          {
            ultim-mc = ultim-mc-wrapped;
            #  devShell = pkgs.mkShell {
            #    buildInputs = [
            #      ultim-mc-wrapped
            #      pkgs.jdk
            #    ];
            #  };
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
