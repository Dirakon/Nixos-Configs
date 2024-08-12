{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; # "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.amnezia-wg.url = "github:amnezia-vpn/amneziawg-go";
  inputs.amnezia-wg.flake = false;

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , amnezia-wg
    , ...
    }:
    let
      amnezia-wg-outputs =
        flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};

            amnezia-wg-built = pkgs.buildGoModule rec {
              pname = "amneziawg-go";
              version = "0.0.20230223";

              vendorHash = "sha256-zXd9PK3fpOx/YjCNs2auZWhbLUk2fO6tyLV5FxAH0us=";
              src = amnezia-wg;

              postPatch = ''
                # Skip formatting tests
                rm -f format_test.go
              '';


              subPackages = [ "." ];

              ldflags = [ "-s" "-w" ];

              # postInstall = ''
              #   mv $out/bin/amneziawg $out/bin/amneziawg-go
              # '';

              # passthru.tests.version = testers.testVersion {
              #   package = wireguard-go;
              #   version = "v${version}";
              # };

              meta = with pkgs.lib; {
                description = "Userspace Go implementation of Amnezia-WG";
                homepage = "https://docs.amnezia.org/documentation/amnezia-wg/";
                license = licenses.mit;
                maintainers = with maintainers; [ ];
                mainProgram = "amneziawg-go";
              };
            };
          in
          {
            amnezia-wg = amnezia-wg-built;
            devShell = pkgs.mkShell {
              buildInputs = [
                amnezia-wg-built
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
