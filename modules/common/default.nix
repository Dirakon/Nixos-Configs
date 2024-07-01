self@{ config, pkgs, boot, unstable, agenix, hostname, ... }:
{
  system.nixos.label = import ./label.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
