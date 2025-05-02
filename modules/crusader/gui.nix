self@{ config
, pkgs
, boot
, godot
, sensitive
, unstable
, ...
}:
{
  environment.systemPackages = with pkgs; [
    # Actual apps
    obsidian
    unstable.trilium-next-desktop
    libreoffice
    telegram-desktop
    mattermost-desktop
    ktorrent
    popsicle

    okular
    gwenview
    kitty
    alacritty
    ghostty
    loupe
    filelight
    ark
    nekoray
    newsflash # rss reader

    # Crypto
    electrum
    framesh
    unstable.bisq2
    unstable.basicswap
    tor-browser

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

  home-manager.users.dirakon =
    {
      xdg.mimeApps.defaultApplications =
        {
          "application/pdf" = "org.kde.okular.desktop";
          "application/x-bittorrent" = "org.kde.ktorrent.desktop";
          "application/zip" = "org.kde.ark.desktop";
          "hoppscotch" = "hoppscotch-handler.desktop";
          "image/gif" = "org.gnome.Loupe.desktop";
          "image/jpeg" = "org.gnome.Loupe.desktop";
          "image/png" = "org.gnome.Loupe.desktop";
          "image/svg+xml" = "org.gnome.Loupe.desktop";
          "image/webp" = "org.gnome.Loupe.desktop";
          "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
          "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
        };

      programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-backgroundremoval
          obs-pipewire-audio-capture
        ];
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
      xdg.mimeApps.defaultApplications."video/x-matroska" = "mpv.desktop";
    };
}
