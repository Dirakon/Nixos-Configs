self@{ config, pkgs, unstable, ... }:
let
  sddmBackgroundPath = pkgs.stdenv.mkDerivation {
    name = "sddm-wallpaper";
    # Using static system file instead of placing relatively to config to not push images to repo
    src = /sddm.jpg;
    buildCommand = ''
      mkdir -p $out
      cp $src $out/sddm.jpg
      ls $out
    '';
  };
in
let
  sddmTheme = pkgs.stdenv.mkDerivation {
    name = "sddm-theme";

    src = pkgs.fetchFromGitHub {
      owner = "MarianArlt";
      repo = "sddm-chili";
      rev = "6516d50176c3b34df29003726ef9708813d06271";
      sha256 = "036fxsa7m8ymmp3p40z671z163y6fcsa9a641lrxdrw225ssq5f3";
    };
    buildInputs = [
      sddmBackgroundPath
    ];

    installPhase = ''
      mkdir -p $out
      cp -R ./* $out/
      rm $out/assets/background.jpg
      echo $sddmBackgroundPath
      cp $buildInputs/sddm.jpg $out/assets/background.jpg
    '';
  };

in
{

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

  # GDM
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.displayManager.gdm.wayland = true;

  # SDDM
  services.xserver.displayManager.sddm.wayland.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.theme = "${sddmTheme}";

  # To try to use CLI-only login. Didn't check with NVIDIA tho.
  # services.xserver.displayManager.startx.enable = true;

  services.displayManager.sessionPackages = [ unstable.hyprland ];

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

    # Thumbnailer stuff for File Managers
    ffmpegthumbnailer
    # folderpreview # Only in AUR 
    evince
    poppler

    # kde components for sddm theme and such
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtgraphicaleffects

    # polkit
    lxqt.lxqt-policykit
  ];

  services.dbus.enable = true;
  xdg.autostart.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  security.pam.services.swaylock = { };
  security.pam.services.kwallet = {
    name = "kwallet";
    enableKwallet = true;
  };

  programs.hyprland.enable = true;
  programs.hyprland.package = unstable.hyprland;
  programs.hyprland.xwayland.enable = true;
  programs.xwayland.enable = true;
  programs.nm-applet.enable = true;

  # Some config service for DEs and WMs??? Not sure
  programs.dconf.enable = true;

  programs.waybar = {
    enable = true;
    package = unstable.waybar;
  };

  services.gvfs.enable = true; # File Managers - Mount, trash and other functionalities
  services.tumbler.enable = true; # File Managers - Thumbnail support for images

  # programs.thunar = {
  #   enable = true;
  #   plugins = with pkgs.xfce; [
  #     thunar-archive-plugin
  #       thunar-volman
  #   ];
  # };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };
}
