{ config, pkgs, ... }:

{
  home.username = "dirakon";
  home.homeDirectory = "/home/dirakon";

  home.file.".config" = {
        source = ./.config;
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


  # Packages that should be installed to the user profile.
#  home.packages = with pkgs; [
#  ];

  programs.neovim = {
    enable = true;
    extraConfig = ''
      set number relativenumber
    '';
  };

  programs.neovim.plugins = [
    pkgs.vimPlugins.nvim-treesitter.withAllGrammars
  ];

  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
