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
      godot-outputs =
        flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};

            use-beta = true;
            stable-version = "4.2.2-stable";
            stable-hash = "sha256-T+Bz/ZnbzbpKi+p4a3ayWk3+4u+m8qoNT0D0Q9Cd4/Q=";
            #beta-version = "4.3-beta2";
            beta-version = "4.3-rc2";
            beta-hash = "sha256-NM/VIe9/zgIggm6H01Jbc/+03g4a1tgGAp3BJUaTP3c=";

            version = if use-beta then beta-version else stable-version;
            hash = if use-beta then beta-hash else stable-hash;

            godot = pkgs.fetchurl {
              url = "https://github.com/godotengine/godot-builds/releases/download/${version}/Godot_v${version}_mono_linux_x86_64.zip";
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
                cp -r source/Godot_v${version}_mono_linux_x86_64/GodotSharp $out/bin/
                cp source/Godot_v${version}_mono_linux_x86_64/Godot_v${version}_mono_linux.x86_64 $out/bin/godot
              '';
            };

            godot-wrapped = pkgs.buildFHSUserEnv {
              name = "godot";
              targetPkgs = pkgs: buildInputs ++ [
                godot-unwrapped
                pkgs.dotnet-sdk_8
                pkgs.omnisharp-roslyn
                pkgs.mono
                pkgs.msbuild
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
