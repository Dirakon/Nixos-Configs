self@{ config, pkgs, hypr-pkgs, hyprland-qtutils, ... }:
{
  services.displayManager.sessionPackages = [ hypr-pkgs.hyprland ];

  imports = [ ./wm-utils.nix ];

  environment.systemPackages = with pkgs; [
    hypr-pkgs.hyprshot
    hyprland-qtutils.default
  ];

  security.pam.services.hyprlock = { };

  # programs.thunar = {
  #   enable = true;
  #   plugins = with pkgs.xfce; [
  #     thunar-archive-plugin
  #       thunar-volman
  #   ];
  # };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
