{

  description = "NixOS configuration";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      #url = "github:nix-community/home-manager/release-23.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flatpaks.url = "github:GermanBread/declarative-flatpak/stable";
    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-gl.url = "github:nix-community/nixGL";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, flatpaks, nix-alien, nix-gl, unstable, agenix, ... }:
    #let overlays = [nix-gl.overlay]; in
    let system = "x86_64-linux"; in
    {
      formatter."${system}" = nixpkgs.legacyPackages."${system}".nixpkgs-fmt;
      nixosConfigurations.nixbox = nixpkgs.lib.nixosSystem {
        system = "${system}";
        specialArgs.unstable = import unstable { system = system; config.allowUnfree = true; };
        specialArgs.nix-gl = nix-gl;
        specialArgs.nix-alien = nix-alien.packages."${system}";
        specialArgs.agenix = agenix.packages."${system}";

        modules = [
          ./hardware-configuration.nix

          ./system.nix

          ./configuration.nix

          ./hyprland.nix

          ./nvidia.nix

          ./nix-ld.nix

          ./flatpak.nix

          agenix.nixosModules.default

          flatpaks.nixosModules.default

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;


            home-manager.users.dirakon = import ./home.nix;
          }
        ];
      };
    };

}
