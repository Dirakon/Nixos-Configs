{

  description = "NixOS configuration";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
     nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
     flatpaks.url = "github:GermanBread/declarative-flatpak/stable"; 
  };

  outputs = inputs@{ self, nixpkgs, home-manager, flatpaks, ... }: {
    nixosConfigurations.nixbox = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
	  ./configuration.nix 

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
