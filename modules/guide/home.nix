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

  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
