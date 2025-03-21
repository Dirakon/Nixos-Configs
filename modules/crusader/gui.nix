self@{ config
, pkgs
, boot
, godot
, ultim-mc
, sensitive
, unstable
, ...
}:
{

  environment.systemPackages = with pkgs; [
    # Wine
    # wine # https://nixos.wiki/wiki/Wine
    wineWowPackages.full
    dxvk
    mesa
    wineWowPackages.fonts
    winetricks
    gst_all_1.gstreamer
    gst_all_1.gst-vaapi
    gst_all_1.gst-libav
    gst_all_1.gstreamermm
    gst_all_1.gst-plugins-rs
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly

    # Further gaming
    jstest-gtk
    joystickwake

    # Actual apps
    obsidian
    libreoffice
    telegram-desktop
    mattermost-desktop
    lutris
    unstable.umu-launcher # TODO: make stable when its there
    rpcs3
    blender
    ktorrent
    popsicle

    okular
    dolphin
    kdePackages.dolphin-plugins
    libsForQt5.dolphin-plugins
    konsole # For dolphin integrated term
    gwenview
    kitty
    alacritty
    ghostty
    krita
    loupe
    kdenlive
    filelight
    ark
    openutau # Eh...
    inkscape
    ultim-mc
    nekoray
    electrum
    framesh
    unstable.bisq2
    unstable.basicswap
    tor-browser
    newsflash # rss reader

    # Dev
    godot
    lmms
    audacity
    # trenchbroom
    hoppscotch

    # doing neovim now
    # jetbrains.rider
    # jetbrains.pycharm-professional
    # jetbrains.webstorm

    # QT theming (cleanup!)
    libsForQt5.kio
    libsForQt5.kio-extras
    libsForQt5.kio-admin

    kio-admin
    kio-fuse

    kdePackages.kio
    kdePackages.kio-extras
    kdePackages.kio-fuse

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

    # latex
    texlive.combined.scheme-full
  ];

  services.blueman.enable = true;
  hardware.bluetooth.enable = true;

  # use wayland for electron
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  # For trenchbroom
  # nixpkgs.config.permittedInsecurePackages = [
  #   "freeimage-unstable-2021-11-01"
  # ];


  home-manager.users.dirakon =
    {
      xdg.mimeApps.defaultApplications."inode/directory" = "dolphin.desktop";

      programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-backgroundremoval
          obs-pipewire-audio-capture
        ];
      };

      services.gammastep = {
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

      services.kdeconnect = {
        enable = true;
        package = pkgs.kdePackages.kdeconnect-kde;
        indicator = true;
      };

      programs.mpv = {
        enable = true;
        scripts = with pkgs.mpvScripts; [
          memo # [h]istory
          mpris # playerctl integration
          autoload # all files in current directory are added to playlist
          uosc # some kinda UI overhaul?
          mpv-cheatsheet # '?' to see keybinds
          thumbfast # thing to display thumnails when scrolling through timeline
        ];
        config = {
          save-position-on-quit = true; # somewhat better history -- remember position too
        };
      };
    };
}
