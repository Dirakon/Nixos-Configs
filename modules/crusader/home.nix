{ config, pkgs, hostname, ... }:

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

    (catppuccin-kvantum.override {
      accent = "Mauve";
      variant = "Mocha";
    })
    libsForQt5.qt5ct
  ];

  # Attempt at GTK theme
  gtk = {
    enable = true;
    theme = {
      # TODO: fix theme
      name = "catppuccin-mocha-blue-compact+default"; #"catppuccin-frappe-standard-lavender-dark";
      package = (pkgs.catppuccin-gtk.overrideAttrs {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "gtk";
          rev = "v1.0.3";
          fetchSubmodules = true;
          hash = "sha256-q5/VcFsm3vNEw55zq/vcM11eo456SYE5TQA3g2VQjGc=";
        };

        postUnpack = "";
      }).override {
        accents = [ "lavender" ];
        size = "standard";
        tweaks = [ "rimless" "black" ];
        variant = "frappe";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "frappe";
        accent = "lavender";
      };
    };
    font = {
      name = "Roboto";
    };
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

  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
