self@{ config, pkgs, boot, hostname, ... }:
{
  system.nixos.label = import ./label.nix;
  # I have no clue why crusader specifically requires 'repl-flake'?
  nix.settings.experimental-features = [ "nix-command" "flakes" ]
    ++ (if hostname == "crusader" then [ "repl-flake" ] else [ ])
  ;
}
