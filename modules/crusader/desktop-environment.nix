self@{ config, pkgs, hypr-pkgs, ... }:
{

  imports = [
    ./desktop/hyprland.nix
    ./desktop/sway.nix
  ];

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    xkb.layout = "us,ru";
    xkb.variant = "";
    videoDrivers = [ "nvidia" ];
    exportConfiguration = true;
  };

  services.dbus.enable = true;
  xdg.autostart.enable = true;
  xdg.portal = {
    enable = true;
    # wlr.enable = true; # Temporary disable for hyprland
    extraPortals = [
      # hypr-pkgs.xdg-desktop-portal-gtk # Apparenty enabled by default - https://github.com/NixOS/nixpkgs/issues/249645
    ];
  };

  security.pam.services.kwallet = {
    name = "kwallet";
    enableKwallet = true;
  };

  # Some config service for DEs and WMs??? Not sure
  programs.dconf.enable = true;

  services.gvfs.enable = true; # File Managers - Mount, trash and other functionalities
  services.tumbler.enable = true; # File Managers - Thumbnail support for images

  # Enable the gnome-keyring secrets vault. 
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;
}
