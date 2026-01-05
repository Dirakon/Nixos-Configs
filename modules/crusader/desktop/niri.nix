self@{ config, pkgs, hypr-pkgs, my-utils, ... }:
let
  hypr-exit-session =
    pkgs.writeShellApplication {
      name = "hypr-exit-session";
      runtimeInputs = [ pkgs.libnotify pkgs.procps hypr-pkgs.uwsm ];
      text = ''
        # throne no longer run with sudo - no need for this logic
        # if pgrep "Throne"; then
        #    notify-send --urgency=critical "Disable throne first please"
        # else
            uwsm stop
        # fi
      '';
    };

in
{
  imports = [ ./wm-utils.nix ];

  programs.niri = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  xdg.configFile."niri/config.kdl".source = ./niri-config.kdl;
}
