{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; # "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.amneziawg-go.url = "github:amnezia-vpn/amneziawg-go";
  inputs.amneziawg-go.flake = false;

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , amneziawg-go
    , ...
    }:
    let
      amneziawg-go-outputs =
        flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};

            amneziawg-go-built = pkgs.buildGoModule rec {
              pname = "amneziawg-go";
              version = "0.0.20230223";

              vendorHash = "sha256-zXd9PK3fpOx/YjCNs2auZWhbLUk2fO6tyLV5FxAH0us=";
              src = amneziawg-go;

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
            amneziawg-go = amneziawg-go-built;
            devShell = pkgs.mkShell {
              buildInputs = [
                amneziawg-go-built
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
    amneziawg-go-outputs // formatter-outputs;
}
