self@{ config, pkgs, hypr-pkgs, hyprland-qtutils, ... }:
{
  services.displayManager.sessionPackages = [ hypr-pkgs.hyprland ];

  imports = [ ./wm-utils.nix ];

  environment.systemPackages = with hypr-pkgs; [
    hyprshot
    hyprland-qtutils.default
    uwsm # <- temp for playing around
  ];

  security.pam.services.hyprlock = { };

  programs.hyprland = {
    enable = true;
    package = hypr-pkgs.hyprland;
    xwayland.enable = true;
    withUWSM = true;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
