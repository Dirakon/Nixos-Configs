self@{ config, pkgs, boot, unstable, ... }:
{
  services.flatpak = {
    enable = true;
    deduplicate = true;
    packages = [
      "flathub:app/org.famistudio.FamiStudio/x86_64/stable" 
    ];
    remotes = {
      "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    };
  };
}
