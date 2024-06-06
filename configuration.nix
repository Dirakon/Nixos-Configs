self@{ config, pkgs, boot, unstable, agenix, ... }:
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
    unstable.ripgrep
    unstable.htop # just to test that unstabling works properly
    unstable.btop
    unstable.fastfetch
    unstable.fuseiso
    unstable.imagemagick
    parted
    gparted
    unstable.tldr
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
    unstable.joystickwake

    # Actual apps
    mpv
    obsidian
    telegram-desktop
    lutris
    unstable.blender
    unstable.ktorrent
    unstable.okular
    unstable.dolphin
    unstable.konsole # For dolphin integrated term
    gwenview
    kitty
    unstable.krita
    unstable.loupe
    unstable.kdenlive
    unstable.filelight
    unstable.ark
    # unstable.openutau # Eh...
    unstable.inkscape

    # Dev
    unstable.jetbrains.rider
    unstable.jetbrains.pycharm-professional
    unstable.jetbrains.webstorm
    unstable.neovide
    gnumake
    cargo
    rustc

    # QT theming (cleanup!)
    # libsForQt5.kio
    libsForQt5.kio-extras
    unstable.kio-admin
    unstable.kio-fuse
    unstable.kdePackages.kio
    unstable.kdePackages.kio-extras
    libsForQt5.kdegraphics-thumbnailers
    libsForQt5.ffmpegthumbs # shold thumbnail videos but not working ...
    unstable.kdePackages.ffmpegthumbs # shold thumbnail videos but not working ...
    # unstable.kdePackages.kdegraphics-thumbnailers # For some reason only qt5 ver works
    unstable.kdePackages.breeze-icons
    kdePackages.qtscxml
    libsForQt5.qt5.qtscxml

    # Gnome theming (cleanup!)
    #gnome.adwaita-icon-theme
    # gnome-icon-theme
    catppuccin-gtk
    # breeze-icons

    # For playing audio
    sox # 'play' command

    # For verilog development
    verilog
    gtkwave
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
  programs.neovim.package = unstable.neovim-unwrapped;

  programs.firefox.enable = true;
  #programs.firefox.package = pkgs.firefox-bin;

  services.geoclue2.enable = true;
}
