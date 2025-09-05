self@{ config
, pkgs
, godot
, lmms
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
    (unstable.pixelorama)
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
      # "flathub:app/com.orama_interactive.Pixelorama/x86_64/stable" # trying nix version
    ];
  };
}
