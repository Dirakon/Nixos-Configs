self@{ config
, pkgs
, boot
, godot
, ultim-mc
, sensitive
, umu
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
    # (python3.pkgs.toPythonApplication sandwine)

    # Further gaming
    jstest-gtk
    joystickwake

    # Actual apps
    obsidian
    libreoffice
    telegram-desktop
    mattermost-desktop
    lutris
    umu
    blender
    ktorrent
    ryujinx
    nsz
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

  # use wayland for electron
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  # For trenchbroom
  # nixpkgs.config.permittedInsecurePackages = [
  #   "freeimage-unstable-2021-11-01"
  # ];

  stylix.enable = true;
  stylix.polarity = "dark";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  # Why is this option mandatory...
  stylix.image = sensitive.crusader.login-background;


}
