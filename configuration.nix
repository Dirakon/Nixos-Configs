{ config, pkgs, ... }:

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

  users.users.dirakon = {
    isNormalUser = true;
    description = "dirakon";
    extraGroups = [ "networkmanager" "wheel" ];
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
    swww
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    xwayland
    firefox
    kitty
    lshw
   # wl-copy
    pkgs.mako
    libnotify
    rofi-wayland
    swaylock
    mpv
    brightnessctl
    obsidian
    telegram-desktop
    lutris
    zip
    unzip
    nix-index
    wineWowPackages.stable
    winetricks
    blender
    xlsclients
  ];
  
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

  hardware.opengl.enable = true; # TODO: more configs?
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
  programs.hyprland.xwayland.enable = true;
  programs.nix-ld.enable = true;
  programs.fish.enable = true;
  programs.command-not-found.enable = false;
  users.defaultUserShell = pkgs.fish;
  programs.steam.enable = true;


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

  programs.waybar = {
    enable = true;
  };

  programs.thunar = {
    enable = true;
  };

  programs.firefox.enable = true;

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

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
