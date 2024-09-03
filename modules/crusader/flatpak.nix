self@{ config, pkgs, boot, ... }:
{
  services.flatpak = {
    enable = true;
    packages = [
      "flathub:app/org.famistudio.FamiStudio/x86_64/stable"
      "flathub:app/com.discordapp.Discord/x86_64/stable"
    ];
    remotes = {
      "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    };
  };
}
