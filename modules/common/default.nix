self@{ config
, pkgs
, boot
, hostname
, ...
}:
{
  system.nixos.label = import ./label.nix;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
