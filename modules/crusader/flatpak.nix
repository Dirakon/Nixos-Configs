self@{ config, pkgs, boot, my-utils, sensitive, ... }:
{
  services.flatpak = my-utils.recursiveMerge [
    ({
      enable = true;
      remotes = {
        "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      };
    })
    (sensitive.crusader.flatpak)
  ]

  ;
}
