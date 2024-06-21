self@{ config, pkgs, boot, agenix, godot, ultim-mc, stable, ... }:
{
  users.users.dirakon = {
    isNormalUser = true;
    description = "dirakon";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" ];
    packages = with pkgs; [ ];
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
    ripgrep
    htop # just to test that unstabling works properly
    btop
    fastfetch
    fuseiso
    imagemagick
    parted
    gparted
    tldr
    arp-scan

    # Nix stuff
    nix-index
    nh
    agenix.default
    docker-compose

    # Wine
    # wine # https://nixos.wiki/wiki/Wine
    wineWowPackages.full
    winetricks

    # Further gaming
    jstest-gtk
    joystickwake

    # Actual apps
    mpv
    obsidian # Fixing weird hash mismatch error
    telegram-desktop
    lutris
    blender
    ktorrent
    okular
    dolphin
    konsole # For dolphin integrated term
    gwenview
    kitty
    krita
    loupe
    kdenlive
    filelight
    ark
    # openutau # Eh...
    inkscape
    ultim-mc

    # Dev
    godot
    jetbrains.rider
    jetbrains.pycharm-professional
    jetbrains.webstorm
    neovide
    gnumake
    cargo
    rustc

    # QT theming (cleanup!)
    # libsForQt5.kio
    libsForQt5.kio-extras
    kio-admin
    kio-fuse
    kdePackages.kio
    kdePackages.kio-extras
    libsForQt5.kdegraphics-thumbnailers
    libsForQt5.ffmpegthumbs # shold thumbnail videos but not working ...
    kdePackages.ffmpegthumbs # shold thumbnail videos but not working ...
    # kdePackages.kdegraphics-thumbnailers # For some reason only qt5 ver works
    kdePackages.breeze-icons
    # kdePackages.qtscxml
    # libsForQt5.qt5.qtscxml

    # Gnome theming (cleanup!)
    #gnome.adwaita-icon-theme
    # gnome-icon-theme
    catppuccin-gtk
    # breeze-icons

    # For playing audio
    sox # 'play' command

    # Performance
    s-tui
    stress

    # For DE interaction with gamepad
    makima
  ];

  # set default browser for Electron apps
  environment.sessionVariables.DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
  # use wayland for electron
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  virtualisation.docker.enable = true;

  programs.fish.enable = true;
  # To overwrite fish command-not-found, which breaks, so we create our own (./.config/fish/config.fish)
  programs.command-not-found.enable = false;
  users.defaultUserShell = pkgs.fish;

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  programs.java.enable = true;

  # Archive app
  # programs.file-roller.enable = true; # Trying Ark for now

  programs.neovim.enable = true;
  programs.neovim.package = pkgs.neovim-unwrapped;

  programs.firefox.enable = true;
  #programs.firefox.package = pkgs.firefox-bin;

  services.geoclue2.enable = true;

  services.zerotierone = {
    enable = true;
    port = 25566;
  };
}
