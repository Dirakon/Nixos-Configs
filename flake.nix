{

  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      #url = "github:nix-community/home-manager";
      url = "github:nix-community/home-manager/release-24.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hypr-pkgs.url = "github:NixOS/nixpkgs/release-24.05";
    # add some more pinning things when needed

    flatpaks.url = "github:GermanBread/declarative-flatpak/stable";
    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-gl.url = "github:nix-community/nixGL";
    sops-nix.url = "github:Mic92/sops-nix";

    call-flake.url = "github:divnix/call-flake";

    disko.url = "github:nix-community/disko";

    nvim.url = "git+file:programs/nvim";
  };

  outputs = inputs:
    #let overlays = [nix-gl.overlay]; in
    let commonModules = [ ./modules/common/default.nix ]; in with inputs;
    {
      # TODO: for each unique system if I ever will actually have mutltiple
      formatter."x86_64-linux" = nixpkgs.legacyPackages."x86_64-linux".nixpkgs-fmt;
      nixosConfigurations.crusader =
        let hostname = "crusader"; in
        let system = "x86_64-linux"; in
        nixpkgs.lib.nixosSystem {
          system = "${system}";
          specialArgs.hostname = "${hostname}";
          specialArgs.hypr-pkgs = import hypr-pkgs { system = system; config.allowUnfree = true; };
          specialArgs.nix-gl = nix-gl;
          specialArgs.nix-alien = nix-alien.packages."${system}";
          specialArgs.sops-nix = sops-nix.packages."${system}";

          specialArgs.godot = (call-flake ./programs/godot).godot."${system}";
          specialArgs.ultim-mc = (call-flake ./programs/ultim-mc).ultim-mc."${system}";
          specialArgs.nvimPackages = nixpkgs.lib.attrsets.attrValues (nvim.packages."${system}".packages);
          specialArgs.amneziawg-go = (call-flake ./programs/amnezia/wg).amneziawg-go."${system}";
          specialArgs.amneziawg-tools = (call-flake ./programs/amnezia/tools).amneziawg-tools."${system}";


          modules = [
            ./modules/${hostname}/default.nix

            sops-nix.nixosModules.default

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

            sops-nix.nixosModules.default

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

      nixosConfigurations.guide2 =
        let hostname = "guide2"; in
        let system = "x86_64-linux"; in
        nixpkgs.lib.nixosSystem {
          system = "${system}";
          specialArgs.hostname = "${hostname}";
          specialArgs.amneziawg-go = (call-flake ./programs/amnezia/wg).amneziawg-go."${system}";
          specialArgs.amneziawg-tools = (call-flake ./programs/amnezia/tools).amneziawg-tools."${system}";

          modules = [
            ./modules/${hostname}/default.nix

            disko.nixosModules.disko

            sops-nix.nixosModules.default

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

      nixosConfigurations.sentinel =
        let hostname = "sentinel"; in
        let system = "x86_64-linux"; in
        nixpkgs.lib.nixosSystem {
          system = "${system}";
          specialArgs.hostname = "${hostname}";
          specialArgs.amneziawg-go = (call-flake ./programs/amnezia/wg).amneziawg-go."${system}";
          specialArgs.amneziawg-tools = (call-flake ./programs/amnezia/tools).amneziawg-tools."${system}";
          specialArgs.unstable = import unstable { system = system; config.allowUnfree = true; };

          modules = [
            ./modules/${hostname}/default.nix

            sops-nix.nixosModules.default

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
