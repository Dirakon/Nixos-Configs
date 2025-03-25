self@{ config, pkgs, boot, ... }:
{
  users.users.dirakon = {
    isNormalUser = true;
    description = "dirakon";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" "uinput" ];
    packages = with pkgs; [ ];
  };

  imports = [
    ./hardware-configuration.nix

    ./home.nix

    ./cli.nix

    ./tmux.nix

    ./nvim.nix

    ./gui.nix

    ./file-explorer.nix

    ./gaming.nix

    ./gamedev.nix

    ./browser.nix

    ./system.nix

    ./display-manager.nix

    ./desktop-environment.nix

    ./nvidia.nix

    ./nix-ld.nix

    ./flatpak.nix

    ./kanata.nix

    ./ssh.nix

    ./switch.nix

    ./theming.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
