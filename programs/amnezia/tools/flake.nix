{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; # "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.amneziawg-tools.url = "github:amnezia-vpn/amneziawg-tools";
  inputs.amneziawg-tools.flake = false;
  inputs.amnziawg-go = "./../wg";

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , amneziawg-tools
    , amnezia-wg
    , ...
    }:
    let
      amnezia-wg-outputs =
        flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};

            amneziawg-tools-built = pkgs.stdenv.mkDerivation rec {
              pname = "amneziawg-tools";
              version = "0.0.20230223";

              src = amneziawg-tools;
              outputs = [ "out" "man" ];

              sourceRoot = "${src.name}/src";

              nativeBuildInputs = [ pkgs.makeWrapper ];

              buildInputs = [ pkgs.bash ];

              makeFlags = [
                "DESTDIR=$(out)"
                "PREFIX=/"
                "WITH_BASHCOMPLETION=yes"
                "WITH_SYSTEMDUNITS=yes"
                "WITH_WGQUICK=yes"
              ];

              postFixup = ''
                substituteInPlace $out/lib/systemd/system/awg-quick@.service \
                  --replace /usr/bin $out/bin
              '' + # pkgs.lib.optionalString pkgs.stdenv.isLinux 
              ''
                for f in $out/bin/*; do
                  # Which firewall and resolvconf implementations to use should be determined by the
                  # environment, we provide the "default" ones as fallback.
                  wrapProgram $f \
                    --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.procps pkgs.iproute2 ]} \
                    --suffix PATH : ${pkgs.lib.makeBinPath [ pkgs.iptables pkgs.openresolv ]}
                done
              '' + #pkgs.lib.optionalString pkgs.stdenv.isDarwin 
              ''
                for f in $out/bin/*; do
                  wrapProgram $f \
                    --prefix PATH : ${pkgs.lib.makeBinPath [ amnezia-wg.amnezia-wg ]}
                done
              '';

              meta = with pkgs.lib; {
                description = "Tools for the Amnezia-WireGuard secure network tunnel";
                longDescription = ''
                  Supplies the main userspace tooling for using and configuring WireGuard tunnels, including the wg(8) and wg-quick(8) utilities.
                  - wg : the configuration utility for getting and setting the configuration of WireGuard tunnel interfaces. The interfaces
                    themselves can be added and removed using ip-link(8) and their IP addresses and routing tables can be set using ip-address(8)
                    and ip-route(8). The wg utility provides a series of sub-commands for changing WireGuard-specific aspects of WireGuard interfaces.
                  - wg-quick : an extremely simple script for easily bringing up a WireGuard interface, suitable for a few common use cases.
                '';
                downloadPage = "https://git.zx2c4.com/wireguard-tools/refs/";
                homepage = "https://www.wireguard.com/";
                license = licenses.gpl2Only;
                maintainers = with maintainers; [ ];
                mainProgram = "awg";
                platforms = platforms.unix;
              };
            };
          in
          {
            amnezia-wg = amneziawg-tools-built;
            devShell = pkgs.mkShell {
              buildInputs = [
                amneziawg-tools-built
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
    amnezia-wg-outputs // formatter-outputs;
}
