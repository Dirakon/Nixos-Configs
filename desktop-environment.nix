self@{ config, pkgs, unstable, ... }:
{

  imports = [ ./hyprland.nix ];

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    xkb.layout = "us,ru";
    xkb.variant = "";
    videoDrivers = [ "nvidia" ];
    exportConfiguration = true;
    # Supposedly fixes intel-vulkan?
    # deviceSection = '' Option      "DRI"    "3" '';
  };

  services.dbus.enable = true;
  xdg.autostart.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
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
}
