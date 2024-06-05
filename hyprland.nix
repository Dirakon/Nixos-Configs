self@{ config, pkgs, stable, unstable, ... }:
{
  services.displayManager.sessionPackages = [ stable.hyprland ];

  # allow brightness editing thru file
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';

  environment.systemPackages = with pkgs; [
    swww # wallpapers
    xdg-desktop-portal-gtk # For file-picker
    unstable.xdg-desktop-portal-hyprland # For everything but file picker
    unstable.wl-clipboard
    unstable.mako # For notifications
    libnotify
    unstable.rofi-wayland # App launcher + clipboard manager frontend
    unstable.cliphist # Clipboard manager backend
    unstable.hyprshot # Screenshots
    swaylock # Lock screen
    networkmanagerapplet
    unstable.swayosd # Frontend for +-brigthness, +-sound
    playerctl # Play controls
    unstable.pavucontrol
    unstable.volumeicon
    unstable.libappindicator
    unstable.libappindicator-gtk3
    unstable.swayidle

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
  programs.hyprland.package = stable.hyprland;
  programs.hyprland.xwayland.enable = true;
  programs.xwayland.enable = true;
  programs.nm-applet.enable = true;

  programs.waybar = {
    enable = true;
    package = stable.waybar;
  };

  # programs.thunar = {
  #   enable = true;
  #   plugins = with pkgs.xfce; [
  #     thunar-archive-plugin
  #       thunar-volman
  #   ];
  # };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
