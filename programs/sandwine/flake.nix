# Broken so far in my scenarios...In particular, a pain to use gpu... TODO: fix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; # "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { self
    , nixpkgs
    , flake-utils
    ,
    }:
    let
      sandwine-outputs =
        flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            version = "4.0.0";
            pname = "sandwine";

            # based on https://github.com/azuwis/nix-config/blob/35524c296dbc36202bef8bf27af8396bcf3e92ec/pkgs/by-name/sa/sandwine/package.nix#L11
            src = pkgs.fetchFromGitHub {
              owner = "hartwork";
              repo = pname;
              rev = version;
              hash = "sha256-pH0Zi4yzOvHQI3Q58o6eOLEBbXheFkRu/AzP8felz5I=";
            };
            sandwine-unwrapped =
              pkgs.python3.pkgs.buildPythonApplication {
                pname = pname;
                version = version;
                format = "pyproject";
                src = src;
                nativeBuildInputs = [ pkgs.python3.pkgs.setuptools ];
                propagatedBuildInputs = with pkgs.python3.pkgs; [ coloredlogs ];

                # makeWrapperArgs = [
                #   ''--prefix PATH : "${
                #     pkgs.lib.makeBinPath [
                #       pkgs.bubblewrap
                #       pkgs.wine64
                #pkgs.coreutils# 
                #     ]
                #   }"''
                # ];
              };
            runInFHSUserEnv =

              # Similar to runInLinuxVM, except we run under a FHS user env instead
              # of a VM. This allows you to use build systems that depend on the FHS
              # without any sort of patching. Resulting binaries may not work on
              # NixOS without wrapping them in FHS though.
              drv: envArgs:
              let
                fhsWrapper = pkgs.buildFHSUserEnv ({
                  name = "${drv.name}-fhs-wrapper";
                  runScript = "$@";
                } // envArgs);
              in
              pkgs.lib.overrideDerivation drv (old: {
                builder = "${fhsWrapper}/bin/${fhsWrapper.name}";
                args = [ old.builder ] ++ old.args;
              });
            sandwine =
              #               runInFHSUserEnv sandwine-unwrapped {
              # 
              #                 targetPkgs = _: (with pkgs; [
              #                   udev
              #                   alsa-lib
              #                   coreutils
              #                   wine64
              #                   bubblewrap
              #                 ]) ++ (with pkgs.xorg; [
              #                   libX11
              #                   libXcursor
              #                   libXrandr
              #                 ]);
              #               };
              # 
              (pkgs.buildFHSEnv {
                name = "snod";
                targetPkgs = pkgs: (with pkgs; [
                  udev
                  alsa-lib
                  coreutils
                  bash
                  # wine64
                  bubblewrap
                  sandwine-unwrapped
                ]) ++ (with pkgs.xorg; [
                  libX11
                  libXcursor
                  libXrandr
                ]);
                runScript = "sandwine";
              });
          in
          {
            sandwine = sandwine;
            devShell = pkgs.mkShell {
              buildInputs = [
                # pkgs.bubblewrap
                #"/run/current-system/sw/bin/sh"
                # pkgs.coreutils
                sandwine
                #(pkgs.python3Packages.toPythonApplication sandwine)
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
    sandwine-outputs // formatter-outputs;
}
