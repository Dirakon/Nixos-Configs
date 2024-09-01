self@{ config
, pkgs
, boot
, agenix
, godot
, ultim-mc
, sandwine
, unstable
, stable
, ...
}:
{

  environment.systemPackages = with pkgs; [
    # Wine
    # wine # https://nixos.wiki/wiki/Wine
    wineWowPackages.full
    winetricks
    (python3.pkgs.toPythonApplication sandwine)

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
    kdePackages.dolphin-plugins
    libsForQt5.dolphin-plugins
    konsole # For dolphin integrated term
    gwenview
    kitty
    alacritty
    krita
    loupe
    kdenlive
    filelight
    ark
    # openutau # Eh...
    inkscape
    ultim-mc
    nekoray
    electrum

    # Dev
    godot
    lmms
    audacity
    trenchbroom

    # doing neovim now
    # jetbrains.rider
    # jetbrains.pycharm-professional
    # jetbrains.webstorm

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

    # For DE interaction with gamepad
    makima

    # For cool self-made DE stuff
    gtkdialog
  ];

  # set default browser for Electron apps
  environment.sessionVariables.DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
  # use wayland for electron
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  # TODO: migrate to home-manager managed one, with extensions
  programs.firefox.enable = true;
  # use if (for some reason) firefox ain't compiled
  #programs.firefox.package = pkgs.firefox-bin;

  services.suwayomi-server = {
    enable = true;

    settings = {
      server.port = 46571;
      server.enableSystemTray = true;
    };
  };

  # For trenchbroom
  nixpkgs.config.permittedInsecurePackages = [
    "freeimage-unstable-2021-11-01"
  ];
}
