self@{ config, pkgs, boot, agenix, godot, ultim-mc, sandwine, stable, ... }:
{
  users.users.dirakon = {
    isNormalUser = true;
    description = "dirakon";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" ];
    packages = with pkgs; [ ];
  };

  imports = [
    ./hardware-configuration.nix

    ./cli.nix

    ./gui.nix

    ./system.nix

    ./display-manager.nix

    ./desktop-environment.nix

    ./nvidia.nix

    ./nix-ld.nix

    ./flatpak.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
