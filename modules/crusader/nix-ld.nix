self@{ config, pkgs, nix-alien, ... }:
{
  environment.systemPackages = with pkgs; [
    nix-alien.nix-alien
  ];

  services.envfs.enable = true;

  programs.nix-ld.enable = true;
}
