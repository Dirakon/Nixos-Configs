{ config, lib, pkgs, unstable, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ];

# For obsidian
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

# Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixbox"; # Define your hostname.
# networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

# Configure network proxy if necessary
# networking.proxy.default = "http://user:password@proxy:port/";
# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

# Enable networking
    networking.networkmanager.enable = true;

# Set your time zone.
  time.timeZone = "Europe/Moscow";

# Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

# Configure keymap in X11
  services.xserver = {
    layout = "ru";
    xkbVariant = "";
    videoDrivers = [ "nvidia" ];
  };
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
    '';
  services.udisks2.enable = true;
  services.upower.enable = true;


  users.users.dirakon = {
    isNormalUser = true;
    description = "dirakon";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [];
  };

# Allow unfree packages
  nixpkgs.config.allowUnfree = true;


# List packages installed in system profile. To search, run:
# $ nix search wget
  environment.systemPackages = with pkgs; [
    vim 
      wget
      git
      firefox
      kitty
      lshw
      zip
      unzip
      unstable.ripgrep
      unstable.htop # Just to test that unstabling works properly

      # Hyprland stuffs
      swww
      xdg-desktop-portal-gtk
      unstable.xdg-desktop-portal-hyprland
      xwayland
      unstable.wl-clipboard
      unstable.mako
      libnotify
      unstable.rofi-wayland
      unstable.cliphist
      unstable.hyprshot
      swaylock
      brightnessctl
      networkmanagerapplet
      unstable.swayosd

      # Nix stuff
      nix-index

      # Wine
      wineWowPackages.stable
      winetricks

      # Actual apps
      mpv
      obsidian
      telegram-desktop
      lutris
      blender
      unstable.ktorrent
      unstable.okular
      unstable.dolphin
      unstable.neovim
      gwenview

      # Dev
      gnumake
      cargo 
      rustc 
      libsForQt5.kio
      libsForQt5.kio-extras
      unstable.kdePackages.kio
      unstable.kdePackages.kio-extras
      libsForQt5.kdegraphics-thumbnailers
      unstable.kdePackages.kdegraphics-thumbnailers
      gnome.adwaita-icon-theme
      gnome-icon-theme
      catppuccin-gtk
      breeze-icons

      # For playing audio
      sox

      # For verilog development
      verilog
      gtkwave

      # Thumbnailer stuff for File Managers
      ffmpegthumbnailer
      # folderpreview # Only in AUR :(
      evince
      poppler
      ]; 

      # set default browser for Electron apps
  environment.sessionVariables.DEFAULT_BROWSER = "${pkgs.firefox}/bin/qutebrowser";

  environment.variables = lib.mkForce {
    QT_STYLE_OVERRIDE = "kvantum";
  };

  sound.enable = true;
  security.rtkit.enable = true;
  security.pam.services.swaylock = {};
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # TODO: more configs?
  hardware.opengl.enable = true; 

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
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

  programs.hyprland.enable = true;
  programs.hyprland.package = unstable.hyprland;
  programs.hyprland.xwayland.enable = true;
  programs.nm-applet.enable = true;
  programs.nix-ld.enable = true;
  programs.fish.enable = true;
  programs.command-not-found.enable = false;
  users.defaultUserShell = pkgs.fish;
  programs.steam.enable = true;

  programs.java.enable = true;

  
  # programs.kvantum = {
  #   enable = true;
  #   theme.package = pkgs.materia-kde-theme;
  #   theme.name = "MateriaDark";
  #   theme.overrides = {
  #     General = {
  #       no_inactiveness = true;
  #       translucent_windows = true;
  #       reduce_window_opacity = 13;
  #       reduce_menu_opacity = 13;
  #       drag_from_buttons = false;
  #       shadowless_popup = true;
  #       popup_blurring = true;
  #       menu_blur_radius = 5;
  #       tooltip_blur_radius = 5;
  #     };
  #     Hacks = {
  #       transparent_dolphin_view = true;
  #       style_vertical_toolbars = true;
  #     };
  #   };
  # };


# Sets up all the libraries to load
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
      openssl
      xorg.libXcomposite
      xorg.libXtst
      xorg.libXrandr
      xorg.libXext
      xorg.libX11
      xorg.libXfixes
      libGL
      libva
# pipewire.lib # Works on https://unix.stackexchange.com/questions/522822/different-methods-to-run-a-non-nixos-executable-on-nixos tho?
      xorg.libxcb
      xorg.libXdamage
      xorg.libxshmfence
      xorg.libXxf86vm
      libelf

# Required
      glib
      gtk2
      bzip2

# Without these it silently fails
      xorg.libXinerama
      xorg.libXcursor
      xorg.libXrender
      xorg.libXScrnSaver
      xorg.libXi
      xorg.libSM
      xorg.libICE
      gnome2.GConf
      nspr
      nss
      cups
      libcap
      SDL2
      libusb1
      dbus-glib
      ffmpeg
# Only libraries are needed from those two
      libudev0-shim

# Verified games requirements
      xorg.libXt
      xorg.libXmu
      libogg
      libvorbis
      SDL
      SDL2_image
      glew110
      libidn
      tbb

# Other things from runtime
      flac
      freeglut
      libjpeg
      libpng
      libpng12
      libsamplerate
      libmikmod
      libtheora
      libtiff
      pixman
      speex
      SDL_image
      SDL_ttf
      SDL_mixer
      SDL2_ttf
      SDL2_mixer
      libappindicator-gtk2
      libdbusmenu-gtk2
      libindicator-gtk2
      libcaca
      libcanberra
      libgcrypt
      libvpx
      librsvg
      xorg.libXft
      libvdpau
      gnome2.pango
      cairo
      atk
      gdk-pixbuf
      fontconfig
      freetype
      dbus
      alsaLib
      expat
# Needed for electron
      libdrm
      mesa
      libxkbcommon
      ];
  zramSwap.enable = true;

  programs.waybar = {
    enable = true;
    package = unstable.waybar;
  };

  services.gvfs.enable = true; # File Managers: Mount, trash, and other functionalities
  services.tumbler.enable = true; # File Managers: Thumbnail support for images

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
        thunar-volman
    ];
  };

  programs.firefox.enable = true;

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    # GTK2_RC_FILES = "/home/dirakon/.config/gtk-2.0/gtkrc";
    # QT_QPA_PLATFORMTHEME = "gtk2";
    # QT_STYLE_OVERRIDE = "gtk2";
  };

  fonts.packages = with pkgs; [
    (unstable.nerdfonts)#.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];

# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };

# List services that you want to enable:

# Enable the OpenSSH daemon.
# services.openssh.enable = true;

# Open ports in the firewall.
# networking.firewall.allowedTCPPorts = [ ... ];
# networking.firewall.allowedUDPPorts = [ ... ];
# Or disable the firewall altogether.
# networking.firewall.enable = false;

  services.flatpak = {
    enable = true;
    deduplicate = true;
    packages = [
      "flathub:app/org.famistudio.FamiStudio/x86_64/stable" 
    ];
    remotes = {
      "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    };
  };


  system.stateVersion = "23.11"; # Install value! Don't change

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
