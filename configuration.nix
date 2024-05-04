self@{ config, pkgs, unstable, nix-alien, nix-gl, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in 
{
  imports =
    [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./label.nix
    ];

# Trying to set it via env var for now!
# system.nixos.label = "test";

  services.thermald.enable = true;
  services.tlp.enable = true;

  nixpkgs.overlays = [ nix-gl.overlay ];

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


# Setup from https://nixos.wiki/wiki/WireGuard to allow wireguard
 networking.firewall.checkReversePath = false; 
  # networking.firewall = {
# # if packets are still dropped, they will show up in dmesg
  #   logReversePathDrops = true;
# # wireguard trips rpfilter up
  #   extraCommands = ''
  #     ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 57798 -j RETURN
  #     ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 57798 -j RETURN
  #     '';
  #   extraStopCommands = ''
  #     ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 57798 -j RETURN || true
  #     ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 57798 -j RETURN || true
  #     '';
  # };

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
    enable = true;
    xkb.layout = "us,ru";
    xkb.variant = "";
    videoDrivers = [ "nvidia" ];
    exportConfiguration = true;
# Supposedly fixes intel-vulkan?
# deviceSection = '' Option      "DRI"    "3" '';
  };

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.displayManager.sessionPackages = [ unstable.hyprland ];
# To try to use CLI-only login. Didn't check with NVIDIA tho.
# services.xserver.displayManager.startx.enable = true;
# allow brightness editing thru file
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


  environment.systemPackages = with pkgs; [ 
# some cli tools
    vim 
    wget
    git
    lshw
    zip
    unzip
    unstable.ripgrep
    unstable.htop # just to test that unstabling works properly
    unstable.btop

# hyprland stuffs
    swww # wallpapers
    xdg-desktop-portal-gtk # For file-picker
    unstable.xdg-desktop-portal-hyprland # For everything but file picker
# xwayland
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

# Nix stuff
    nix-index
    nix-alien.nix-alien
# pkgs.nixgl.nixGLIntel # If encounter some openGL problem look into this
# pkgs.nixgl.auto.nixGLDefault # broken for some reason
    glxinfo
    nvidia-offload
    vulkan-loader
    nh

# Wine
    # wine # https://nixos.wiki/wiki/Wine
    wineWowPackages.full
    winetricks
    
    jstest-gtk

# Actual apps
    mpv
    obsidian
    telegram-desktop
    lutris
    blender
    unstable.ktorrent
    unstable.okular
    unstable.dolphin
    gwenview
    firefox
    kitty
    unstable.krita
    unstable.loupe
    unstable.kdenlive
    unstable.filelight
    # unstable.openutau # Eh...

# Dev
    unstable.jetbrains.rider
    unstable.jetbrains.pycharm-professional
    unstable.jetbrains.webstorm
    gnumake
    cargo 
    rustc 

# QT theming (cleanup!)
    libsForQt5.kio
    libsForQt5.kio-extras
    unstable.kdePackages.kio
    unstable.kdePackages.kio-extras
    libsForQt5.kdegraphics-thumbnailers
    unstable.kdePackages.kdegraphics-thumbnailers
    libsForQt5.breeze-qt5
    # unstable.breeze
    unstable.kdePackages.breeze-icons

# Gnome theming (cleanup!)
    gnome.adwaita-icon-theme
    gnome-icon-theme
    catppuccin-gtk
    breeze-icons

# For playing audio
    sox # 'play' command

# For verilog development
    verilog
    gtkwave

# Thumbnailer stuff for File Managers
    ffmpegthumbnailer
# folderpreview # Only in AUR 
    evince
    poppler
    ]; 

# set default browser for Electron apps
  environment.sessionVariables.DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";

  # environment.variables.QT_STYLE_OVERRIDE = "kvantum";

  sound.enable = true;
  security.rtkit.enable = true;
  security.pam.services.swaylock = {};
  security.pam.services.kwallet = {
    name = "kwallet";
    enableKwallet = true;
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  hardware.opengl.enable = true; 
  hardware.opengl.extraPackages = with pkgs;[ 
    rocm-opencl-icd
    rocm-opencl-runtime
    mesa.drivers 
  ];

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
# for using specific driver version:
# .beta.overrideAttrs {
#   version = "550.40.07";
# t#he new driver
#   src = pkgs.fetchurl
#   {
#     url = "https://download.nvidia.com/XFree86/Linux-x86_64/550.40.07/NVIDIA-Linux-x86_64-550.40.07.run";
#     sha256 = "sha256-KYk2xye37v7ZW7h+uNJM/u8fNf7KyGTZjiaU03dJpK0=";
#   };
# };    
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
  hardware.nvidia.nvidiaPersistenced = true;
  hardware.nvidia.prime.allowExternalGpu = true;

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
  programs.xwayland.enable = true; 
  programs.nm-applet.enable = true;

  programs.fish.enable = true;
# To overwrite fish command-not-found, which breaks, so we create our own (./.config/fish/config.fish)
  programs.command-not-found.enable = false;
  users.defaultUserShell = pkgs.fish;

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  programs.java.enable = true;

# Archive app
  programs.file-roller.enable = true;

  programs.neovim.enable = true;
  programs.neovim.package = unstable.neovim-unwrapped;

# ???
  programs.dconf.enable = true;

  programs.nix-ld.enable = true;
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

  services.gvfs.enable = true; # File Managers - Mount, trash and other functionalities
    services.tumbler.enable = true; # File Managers - Thumbnail support for images

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
