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
    libreoffice
    telegram-desktop
    mattermost-desktop
    blender
    ktorrent
    popsicle

    okular
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
    nekoray
    newsflash # rss reader

    # Crypto
    electrum
    framesh
    unstable.bisq2
    unstable.basicswap

    tor-browser
    # Dev
    godot
    lmms
    audacity
    # trenchbroom
    hoppscotch

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

  # For trenchbroom
  # nixpkgs.config.permittedInsecurePackages = [
  #   "freeimage-unstable-2021-11-01"
  # ];


  home-manager.users.dirakon =
    {
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
