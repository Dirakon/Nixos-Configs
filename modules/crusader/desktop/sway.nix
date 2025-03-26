self@{ config, lib, pkgs, hypr-pkgs, ... }:
let
  i3-toolwait =
    pkgs.writeShellApplication {
      name = "i3-toolwait";
      runtimeInputs = [
        (pkgs.python3.withPackages (python-pkgs: [
          python-pkgs.i3ipc
        ]))
      ];
      text = ''
        python3 "${./i3-toolwait.py}" "$@"
      '';
    };
in
let
  sway-start-apps =
    pkgs.writeShellApplication {
      name = "sway-start-apps";
      runtimeInputs = [ pkgs.sway i3-toolwait pkgs.kitty ];
      text = ''
        # workspace 0
        swaymsg -q 'workspace 10'
        i3-toolwait --nocheck -v -- kitty --hold sh -c 'sudo -E nekoray'

        # go back to default - workspace 1
        swaymsg -q 'workspace 1'

        # TODO: notes on n? browser on b?
      '';
    };
in
{
  services.displayManager.sessionPackages = [ pkgs.sway ];

  imports = [ ./wm-utils.nix ];

  environment.systemPackages = with pkgs; [
    autotiling
    i3-swallow # <- this works better
    i3-toolwait
    sway-start-apps
  ];

  programs.sway = {
    enable = true;
    extraPackages = [ ];
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export SUDO_ASKPASS="${pkgs.ksshaskpass}/bin/ksshaskpass"
      export SSH_ASKPASS="${pkgs.ksshaskpass}/bin/ksshaskpass"
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=sway
    '';
    extraOptions = [ "--unsupported-gpu" ];
  };

  environment.sessionVariables = {
    # WLR_RENDERER = "vulkan";
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
