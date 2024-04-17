



{
 # inputs = {
  #  nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # home-manager, used for managing user configuration
  #  home-manager = {
  #    url = "github:nix-community/home-manager/release-23.11";
  #    # The `follows` keyword in inputs is used for inheritance.
  #    # Here, `inputs.nixpkgs` of home-manager is kept consistent with
  #    # the `inputs.nixpkgs` of the current flake,
  #    # to avoid problems caused by different versions of nixpkgs.
  #    inputs.nixpkgs.follows = "nixpkgs";
  #  };
  #};

  inputs = {
    # NOTE: Replace "nixos-23.11" with that which is in system.stateVersion of
    # configuration.nix. You can also use latter versions if you wish to
    # upgrade.
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };
  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations.nixbox = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
	./configuration.nix 

      #	  # make home-manager as a module of nixos
      #    # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
      #    home-manager.nixosModules.home-manager
      #    {
      #      home-manager.useGlobalPkgs = true;
      #      home-manager.useUserPackages = true;

      #      home-manager.users.dirakon = import ./home.nix;
      #    }	
      ];
    };
  };

}
