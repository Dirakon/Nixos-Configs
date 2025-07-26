self@{ config
, pkgs
, godot
, sensitive
, unstable
, ...
}:
{
  environment.systemPackages = with pkgs; [
    blender
    krita
    openutau # Eh...
    inkscape
    godot
    # pixelorama # using flatpak version because I want 1.11.2
    lmms
    audacity
    kdePackages.kdenlive
    gimp3-with-plugins
    # trenchbroom
    (unstable.famistudio)
  ];

  services.flatpak = {
    packages = [
      # "flathub:app/org.famistudio.FamiStudio/x86_64/stable" # trying nix version
      "flathub:app/com.orama_interactive.Pixelorama/x86_64/stable"
    ];
  };
}
