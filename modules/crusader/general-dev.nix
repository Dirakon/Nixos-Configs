self@{ config
, pkgs
, godot
, sensitive
, unstable
, ...
}:
{
  environment.systemPackages = with pkgs; [
    vim
    hoppscotch
    posting

    # Nix stuff
    nix-index
    nh
    docker-compose
    distrobox
    sops
  ];

  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

  programs.java.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Easy shell environments
  home-manager.users.dirakon.programs.direnv =
    {
      enable = true;
      enableFishIntegration = true;
      silent = true;
      nix-direnv.enable = true;
    };
}
