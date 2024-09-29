{ config
, pkgs
, hostname
, ...
}:

{
  home.username = "dirakon";
  home.homeDirectory = "/home/dirakon";

  # https://github.com/nix-community/home-manager/issues/3849
  home.file."dumpDirectlyToHomeFolder" = {
    target = "fake/..";
    source = ./../../home/${hostname};
    recursive = true;
  };
  home.file.".scripts/nix-command-not-found" = {
    text = ''
      #!/usr/bin/env bash
            source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
            command_not_found_handle "$@"
    '';

    executable = true;
  };

  imports = [
    ./helix.nix
  ];

  # Attempt at QT theme
  #  qt.enable = true;
  #  qt.platformTheme = "qtct";
  #  # qt.style.name = "adwaita-dark";
  #  # qt.style.package = pkgs.adwaita-qt;
  #  home.packages = [ pkgs.libsForQt5.qt5ct ]; 

  # qt.enable = true;
  # qt.platformTheme.name = "qtct"; 
  # qt.style.name = "kvantum";

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style = {
      name = "kvantum";
      #   #package = pkgs.catppuccin-kde.override {
      #   #  flavour = ["frappe"];
      #   #  accents = ["pink"];
      #   #};
    };
  };

  home.packages = with pkgs; [

    #  (catppuccin-kvantum.override {
    #    accent = "Mauve";
    #    variant = "Mocha";
    #  })
    libsForQt5.qt5ct
  ];

  gtk = {
    #  enable = true;
    #  theme = {
    #    #name = "Arc-Dark";
    #    #package = pkgs.arc-theme;
    #    name = "Adwaita-dark";
    #    package = pkgs.gnome.gnome-themes-extra;
    #  };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    #  gtk3.extraConfig = {
    #    Settings = ''
    #      gtk-application-prefer-dark-theme=1
    #    '';
    #  };
    #  gtk4.extraConfig = {
    #    Settings = ''
    #      gtk-application-prefer-dark-theme=1
    #    '';
    #  };
  };

  # Packages that should be installed to the user profile.
  #  home.packages = with pkgs; [
  #  ];



  programs.kitty = {
    theme = "Tokyo Night Storm";
  };

  # Easy shell environments
  programs.direnv = {
    enable = true;
    # enableNushellIntegration = true;
    # enableZshIntegration = true;
    enableFishIntegration = true;
    # Re-enable when Nix versioning issue is sorted
    #nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

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

  services.swayosd.enable = true;

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      memo # [h]istory
      mpris # playerctl integration
      autoload # all files in current directory are added to playlist
      uosc # some kinda UI overhaul?
      mpv-cheatsheet # ? to see keybinds
      thumbfast # thing to display thumnails when scrolling through timeline
    ];
    config = {
      save-position-on-quit = true; # somewhat better history -- remember position too
    };
  };

  # Use dolphin as default file manager
  xdg.mimeApps.defaultApplications."inode/directory" = "dolphin.desktop";

  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
