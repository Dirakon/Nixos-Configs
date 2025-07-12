{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    deprecated-pkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      #url = "github:nix-community/home-manager";
      url = "github:nix-community/home-manager/release-25.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix/release-25.05";

    hypr-pkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # hypr-pkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    # add some more pinning things when needed

    flatpaks.url = "github:GermanBread/declarative-flatpak/stable-v3";
    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-gl.url = "github:nix-community/nixGL";
    sops-nix.url = "github:Mic92/sops-nix";

    call-flake.url = "github:divnix/call-flake";

    disko.url = "github:nix-community/disko";

    nvim.url = "git+file:programs/nvim";
    mattermost-printer-bot.url = "git+file:programs/mattermost-printer-bot";
    mattermost-youtube-bot.url = "git+file:programs/mattermost-youtube-bot";

    sensitive.url = "git+file:sensitive";

    # ds4drv.url = "github:Banh-Canh/ds4drv";
    ds4drv.url = "github:clearpathrobotics/ds4drv";
    ds4drv.flake = false;
  };

  outputs = inputs:
    let overlays = import ./overlays.nix inputs; in
    let my-utils = import ./modules/common/utils.nix; in
    let
      commonModules = [
        ./modules/common/default.nix
        {
          nixpkgs.overlays = overlays;
        }
      ];
    in
    with inputs;
    {
      # TODO: for each unique system if I ever will actually have mutltiple
      formatter."x86_64-linux" = nixpkgs.legacyPackages."x86_64-linux".nixpkgs-fmt;
      nixosConfigurations.crusader =
        let hostname = "crusader"; in
        let system = "x86_64-linux"; in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs =
            {
              inherit hostname sensitive my-utils ds4drv;
              hypr-pkgs = import hypr-pkgs {
                system = system;
                config.allowUnfree = true;
              };
              deprecated-pkgs = import deprecated-pkgs {
                system = system;
                config.allowUnfree = true;
              };
              unstable = import unstable {
                system = system;
                config.allowUnfree = true;
              };
              unstable-raw = unstable;
              nix-gl = nix-gl;
              nix-alien = nix-alien.packages."${system}";
              sops-nix = sops-nix.packages."${system}";

              godot = (call-flake ./programs/godot).godot."${system}";
              ultim-mc = (call-flake ./programs/ultim-mc).ultim-mc."${system}";
              nvimPackages = nvim.packages."${system}".packages;
              amneziawg-go = (call-flake ./programs/amnezia/wg).amneziawg-go."${system}";
              amneziawg-tools = (call-flake ./programs/amnezia/tools).amneziawg-tools."${system}";
            };


          modules = [
            ./modules/${hostname}/default.nix

            sops-nix.nixosModules.default

            flatpaks.nixosModule

            stylix.nixosModules.stylix

            home-manager.nixosModules.home-manager
          ] ++ commonModules;
        };

      nixosConfigurations.rat =
        let hostname = "rat"; in
        let system = "x86_64-linux"; in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs =
            {
              inherit hostname sensitive my-utils;
              deprecated-pkgs = import deprecated-pkgs {
                system = system;
                config.allowUnfree = true;
              };
              unstable = import unstable {
                system = system;
                config.allowUnfree = true;
              };
            };


          modules = [
            ./modules/${hostname}/default.nix

            sops-nix.nixosModules.default

            home-manager.nixosModules.home-manager
          ] ++ commonModules;
        };

      nixosConfigurations.guide =
        let hostname = "guide"; in
        let system = "x86_64-linux"; in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs =
            {
              inherit hostname sensitive my-utils;
            };

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
                  inherit config pkgs hostname sensitive;
                });
            }
          ] ++ commonModules;
        };

      nixosConfigurations.guide2 =
        let hostname = "guide2"; in
        let system = "x86_64-linux"; in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs =
            {
              inherit hostname sensitive my-utils;
              amneziawg-go = (call-flake ./programs/amnezia/wg).amneziawg-go."${system}";
              amneziawg-tools = (call-flake ./programs/amnezia/tools).amneziawg-tools."${system}";
            };

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
                  inherit config pkgs hostname sensitive;
                });
            }
          ] ++ commonModules;
        };

      nixosConfigurations.sentinel =
        let hostname = "sentinel"; in
        let system = "x86_64-linux"; in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs =
            {
              inherit hostname sensitive my-utils;
              amneziawg-go = (call-flake ./programs/amnezia/wg).amneziawg-go."${system}";
              amneziawg-tools = (call-flake ./programs/amnezia/tools).amneziawg-tools."${system}";
              unstable = import unstable { system = system; config.allowUnfree = true; };
              mattermost-printer-bot = mattermost-printer-bot.packages."${system}".default;
              mattermost-youtube-bot = mattermost-youtube-bot.packages."${system}".default;
            };

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
                  inherit config pkgs hostname sensitive;
                });
            }
          ] ++ commonModules;
        };
    };
}
