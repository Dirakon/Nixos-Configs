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

  # Easy shell environments
  programs.direnv = {
    enable = true;
    # enableNushellIntegration = true;
    # enableZshIntegration = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
    silent = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
