{

  description = "NixOS configuration";

  inputs = {
    home-manager = {
      #url = "github:nix-community/home-manager";
      url = "github:nix-community/home-manager/release-24.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";
    #nixpkgs.url = "github:NixOS/nixpkgs/57d6973abba7ea108bac64ae7629e7431e0199b6";
    #nixpkgs.url = "github:Failed to mount /usr/bin.NixOS/nixpkgs/release-24.05";
    #unstable.url = "github:NixOS/nixpkgs/release-24.05";
    unstable.url = "github:NixOS/nixpkgs/57d6973abba7ea108bac64ae7629e7431e0199b6";
    stable.url = "github:NixOS/nixpkgs/release-24.05";

    hypr-pkgs.url = "github:NixOS/nixpkgs/release-24.05";
    # .37 - ??? - 
    # .38 - ??? - "github:NixOS/nixpkgs/52c9b9d1b1cde669fea26505c3911ccd03e814c5"; # Gpu flakey
    # .39 - ??? - "github:NixOS/nixpkgs/656721f99caa8df33cdbb3cd7910848658489026"; # Gpu flakey
    # .40 - unstable - "github:NixOS/nixpkgs/4b55bfc815d996f3fc3cba96e343c744156ccf73"; # Gpu works fine

    flatpaks.url = "github:GermanBread/declarative-flatpak/stable";
    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-gl.url = "github:nix-community/nixGL";
    agenix.url = "github:ryantm/agenix";

    godot.url = "./programs/godot/";
    ultim-mc.url = "./programs/ultim-mc/";
    sandwine.url = "./programs/sandwine/";

    disko.url = "github:nix-community/disko";
  };

  outputs = inputs@{ self, nixpkgs, hypr-pkgs, home-manager, flatpaks, nix-alien, nix-gl, unstable, agenix, godot, ultim-mc, sandwine, stable, disko, ... }:
    #let overlays = [nix-gl.overlay]; in
    let commonModules = [ ./modules/common/default.nix ]; in
    {
      # TODO: for each unique system if I ever will actually have mutltiple
      formatter."x86_64-linux" = nixpkgs.legacyPackages."x86_64-linux".nixpkgs-fmt;
      nixosConfigurations.crusader =
        let hostname = "crusader"; in
        let system = "x86_64-linux"; in
        nixpkgs.lib.nixosSystem {
          system = "${system}";
          specialArgs.hostname = "${hostname}";
          specialArgs.unstable = import unstable { system = system; config.allowUnfree = true; };
          specialArgs.stable = import stable { system = system; config.allowUnfree = true; };
          specialArgs.hypr-pkgs = import hypr-pkgs { system = system; config.allowUnfree = true; };
          specialArgs.nix-gl = nix-gl;
          specialArgs.godot = godot.godot."${system}";
          specialArgs.ultim-mc = ultim-mc.ultim-mc."${system}";
          specialArgs.sandwine = sandwine.sandwine."${system}";
          specialArgs.nix-alien = nix-alien.packages."${system}";
          specialArgs.agenix = agenix.packages."${system}";

          modules = [
            ./modules/${hostname}/default.nix

            agenix.nixosModules.default

            flatpaks.nixosModules.default

            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;


              home-manager.users.dirakon =
                ({ config, pkgs, ... }: import ./modules/${hostname}/home.nix {
                  inherit config pkgs;
                  hostname = hostname;
                });
            }
          ] ++ commonModules;
        };

      nixosConfigurations.guide =
        let hostname = "guide"; in
        let system = "x86_64-linux"; in
        nixpkgs.lib.nixosSystem {
          system = "${system}";
          specialArgs.hostname = "${hostname}";

          modules = [
            ./modules/${hostname}/default.nix

            disko.nixosModules.disko

            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.dirakon =
                ({ config, pkgs, ... }: import ./modules/${hostname}/home.nix {
                  inherit config pkgs;
                  hostname = hostname;
                });
            }
          ] ++ commonModules;
        };
    };
}
