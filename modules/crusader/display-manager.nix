self@{ config, pkgs, ... }:
{
  # GDM
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.displayManager.gdm.wayland = true;

  # To try to use CLI-only login. Didn't check with NVIDIA tho.
  # services.xserver.displayManager.startx.enable = true;

  # SDDM
  imports = [ ./sddm.nix ];
}
