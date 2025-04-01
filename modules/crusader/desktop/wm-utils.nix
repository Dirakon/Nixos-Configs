self@{ config, pkgs, hypr-pkgs, ... }:
{
  # allow brightness editing thru file
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';

  environment.systemPackages = with pkgs; [
    hypr-pkgs.swww # wallpapers
    # hypr-pkgs.xdg-desktop-portal-gtk # Apparenty enabled by default - https://github.com/NixOS/nixpkgs/issues/249645
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
  programs.xwayland.enable = true;
  programs.xwayland.package = hypr-pkgs.xwayland;
  programs.nm-applet.enable = true;

  programs.waybar = {
    enable = true;
    package = hypr-pkgs.waybar;
  };

  # Gammastep

  # Enable automatic time synchronization
  services.geoclue2 = {
    enable = true;
    # https://github.com/NixOS/nixpkgs/issues/321121
    geoProviderUrl = "https://beacondb.net/v1/geolocate";
    submitData = false;
    appConfig.gammastep = {
      isAllowed = true;
      isSystem = true;
    };
  };
  location.provider = "geoclue2";
  home-manager.users.dirakon.services.gammastep = {
    tray = true;
    enable = true;
    #    enableVerboseLogging = true;
    provider = "geoclue2";
    #    temperature = {
    #      day = 6000;
    #      night = 4600;
    #    };

    settings = {
      general.adjustment-method = "wayland";
    };
  };

  home-manager.users.dirakon.services.swayosd = {
    enable = true;
    package = hypr-pkgs.swayosd;
  };
}
