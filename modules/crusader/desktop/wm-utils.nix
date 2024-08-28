self@{ config, pkgs, hypr-pkgs, unstable, ... }:
{
  # allow brightness editing thru file
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';

  environment.systemPackages = with pkgs; [
    hypr-pkgs.swww # wallpapers
    hypr-pkgs.xdg-desktop-portal-gtk
    hypr-pkgs.wl-clipboard
    hypr-pkgs.mako # For notifications
    hypr-pkgs.rofi-wayland # App launcher + clipboard manager frontend
    hypr-pkgs.cliphist # Clipboard manager backend
    hypr-pkgs.swaylock # Lock screen
    hypr-pkgs.swayosd # Frontend for +-brigthness, +-sound
    hypr-pkgs.swayidle
    libnotify
    playerctl # Play controls
    networkmanagerapplet
    pavucontrol
    volumeicon
    libappindicator
    libappindicator-gtk3

    # Thumbnailer stuff for File Managers
    ffmpegthumbnailer
    # folderpreview # Only in AUR 
    evince
    poppler

    # polkit
    lxqt.lxqt-policykit
  ];

  security.pam.services.swaylock = { };
  programs.hyprland.enable = true;
  programs.hyprland.package = hypr-pkgs.hyprland;
  programs.hyprland.xwayland.enable = true;
  programs.xwayland.enable = true;
  programs.xwayland.package = hypr-pkgs.xwayland;
  programs.nm-applet.enable = true;

  programs.waybar = {
    enable = true;
    package = hypr-pkgs.waybar;
  };


}
