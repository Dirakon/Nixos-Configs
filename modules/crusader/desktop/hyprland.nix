self@{ config, pkgs, hypr-pkgs, hyprland-qtutils, ... }:
let
  hypr-exit-session =
    pkgs.writeShellApplication {
      name = "hypr-exit-session";
      runtimeInputs = [ pkgs.libnotify pkgs.procps pkgs.uwsm ];
      text = ''
        if pgrep "nekoray"; then
           notify-send --urgency=critical "Disable nekoray first please"
        else
            uwsm stop
        fi
      '';
    };
in
{
  imports = [ ./wm-utils.nix ];

  environment.systemPackages = with hypr-pkgs; [
    hyprshot
    hyprland-qtutils.default
    hypr-pkgs.uwsm
    hypr-exit-session
  ];

  security.pam.services.hyprlock = { };

  programs.hyprland = {
    enable = true;
    package = hypr-pkgs.hyprland;
    xwayland.enable = true;
    withUWSM = true;
  };

  programs.uwsm = {
    enable = true;
    package = pkgs.uwsm;
  };

  # Run XDG autostart, this is needed for a DE-less setup like Hyprland
  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
