{ config, pkgs, ... }:

{
  home.username = "dirakon";
  home.homeDirectory = "/home/dirakon";

  home.file.".config" = {
    source = ./.config;
    recursive = true;
  };
  home.file.".scripts" = {
    source = ./.scripts;
    recursive = true;
    executable = true;
  };
  home.file.".assets" = {
    source = ./.assets;
    recursive = true;
  };
  home.file."bin/nix-command-not-found" = {
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

qt.enable = true;
qt.platformTheme = "qtct";
qt.style.name = "kvantum";

home.packages = with pkgs; [

  (catppuccin-kvantum.override {
    accent = "Mauve";
    variant = "Mocha";
  })
];

# environment.variables = {
#   QT_QPA_PLATFORMTHEME="gtk2";
#  };

# Attempt at GTK theme
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Frappe-Standard-Lavender-Dark";
      package = pkgs.catppuccin-gtk.override {
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

  services.swayosd.enable = true;

  home.stateVersion = "23.11";

# Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
