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
    lmms
    audacity
    kdenlive
    # trenchbroom
  ];
}
