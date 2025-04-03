self@{ config, pkgs, nix-alien, nix-gl, ... }:
{
  nixpkgs.overlays = [ nix-gl.overlay ];

  environment.systemPackages = with pkgs; [
    nix-alien.nix-alien
    # pkgs.nixgl.nixGLIntel # If encounter some openGL problem look into this
    # pkgs.nixgl.auto.nixGLDefault # broken for some reason
  ];

  services.envfs.enable = true;

  programs.nix-ld.enable = true;
}
