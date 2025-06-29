self@{ config
, pkgs
  # , godot
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
    # godot
    godot-mono
    lmms
    audacity
    kdePackages.kdenlive
    gimp3-with-plugins
    # trenchbroom
  ];

  services.flatpak = {
    packages = [
      "flathub:app/org.famistudio.FamiStudio/x86_64/stable"
    ];
  };
}
