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
  home.file."bin/nix-command-not-found" = {
        text = ''
          #!/usr/bin/env bash
          source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
          command_not_found_handle "$@"
        '';
 
         executable = true;
       };

  qt.enable = true;
  qt.platformTheme = "gtk";
  qt.style.name = "adwaita-dark";
  qt.style.package = pkgs.adwaita-qt;

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
      # gtk3.extraConfig.gtk-decoration-layout = "menu:";
      # theme = {
      #   name = "Tokyonight-Dark-B";
      #   package = pkgs.tokyo-night-gtk;
      # };
      # iconTheme = {
      #   name = "Tokyonight-Dark";
      # };
      # cursorTheme = {
      #   name = gtkCursorTheme;
      #   package = pkgs.bibata-cursors;
      # };
    };
  # try when having libadwaita problems (from https://discourse.nixos.org/t/setting-nautiilus-gtk-theme/38958)
  #home.sessionVariables.GTK_THEME = "Tokyonight-Dark-B";
  # # or
  # xdg.configFile = {
  # "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
  # "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
  # "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  # };

  # Packages that should be installed to the user profile.
#  home.packages = with pkgs; [
#  ];

#  programs.neovim = {
#    enable = true;
#    extraConfig = ''
#      set number relativenumber
#    '';
#  };

  # programs.neovim.plugins = [
  #   pkgs.vimPlugins.nvim-treesitter.withAllGrammars
  # ];
  #services.batsignal.enable = true; ain't working
  programs.kitty = {
      theme = "Tokyo Night Storm";
  };

  services.swayosd.enable = true;
  # services.swayosd.package = unstable.swayosd; # Gotta learn how to push unstable into home


  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
