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
      godot-outputs =
        flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};

            version = "4.6";
            flavor = "rc2";
            hash = "sha256-O2R6WM4rMHPBReNvEs2wI9mciqoOFMuHKzUDfYcZOAo=";

            godot = pkgs.fetchurl {
              url = "https://downloads.godotengine.org/?version=${version}&flavor=${flavor}&slug=mono_linux_x86_64.zip&platform=linux.64";
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
              vulkan-loader # IMPORTANT! SOLVES BUG OF CPU START EVEN WITH NVIDIA-OFFLOAD somehow
              xorg.libX11
              xorg.libXcursor
              xorg.libXinerama
              xorg.libXrandr
              xorg.libXrender
            ];



            godot-unwrapped = pkgs.stdenv.mkDerivation {
              pname = "godot";
              version = "${version}";

              src = godot;
              nativeBuildInputs = with pkgs; [ unzip autoPatchelfHook ];
              buildInputs = buildInputs;


              runtimeDependencies = with pkgs; [
                #vulkan-loader
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
                #        libdecor # <- For client-side decorations (look bad)
              ];

              dontAutoPatchelf = false;

              unpackPhase = ''
                mkdir source
                unzip $src -d source
              '';

              installPhase = ''
                mkdir -p $out/bin
                cp -r source/Godot_v${version}-${flavor}_mono_linux_x86_64/GodotSharp $out/bin/
                cp source/Godot_v${version}-${flavor}_mono_linux_x86_64/Godot_v${version}-${flavor}_mono_linux.x86_64 $out/bin/godot
              '';
            };

            godot-wrapped = pkgs.buildFHSEnv {
              name = "godot";
              targetPkgs = pkgs: buildInputs ++ [
                godot-unwrapped
                # pkgs.dotnet-sdk_9
                # pkgs.omnisharp-roslyn
                # pkgs.mono
                # pkgs.msbuild
              ];
              runScript = "godot";
            };
          in
          {
            godot = godot-wrapped;

            #     pkgs.mkShell {
            #       buildInputs = [
            #         godot-wrapped
            #           pkgs.dotnet-sdk_8
            #           pkgs.omnisharp-roslyn
            #           pkgs.mono
            #           pkgs.msbuild
            # 
            #pkgs.glslang # or shaderc
            #pkgs.vulkan-headers
            #pkgs.vulkan-loader
            #pkgs.vulkan-tools
            #pkgs.vulkan-validation-layers # maybe?

            #       ];
            #     };
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
    godot-outputs // formatter-outputs;
}
