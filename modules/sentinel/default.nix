self@{ config, pkgs, boot, agenix, godot, ultim-mc, sandwine, stable, ... }:
{
  users.users.dirakon = {
    isNormalUser = true;
    description = "dirakon";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" "uinput" ];
    packages = with pkgs; [ ];
  };

  imports = [
    ./hardware-configuration.nix

    ./cli.nix

    ./system.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.trusted-users = [ "dirakon" ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF03uj/UUSxx19vzMgnrfOwIflPP//GVHl2gIA4OYnlS dirakon@nixbox"
  ];
  users.users.dirakon.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF03uj/UUSxx19vzMgnrfOwIflPP//GVHl2gIA4OYnlS dirakon@nixbox"
  ];
}