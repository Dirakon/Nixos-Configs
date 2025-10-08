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

    ./cli.nix

    ./hyprland.nix

    ./mpv.nix

    ./xray.nix

    ./syncthing.nix

    ./system.nix

    ./sops.nix

    ./amnezia.nix

    ./suwayomi.nix

    ./nextcloud.nix

    # ./jellyfin.nix

    ./gitea.nix

    ./mattermost.nix

    ./printing.nix

    ./languagetool.nix

    # broken atm - need to research https://discourse.nixos.org/t/firefox-sync-401-login-failed-due-to-misconfigured-nginx/61313/12
    # i think nginx problems?
    ./firefox-sync.nix
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

  services.openssh.settings.PasswordAuthentication = false;
}
