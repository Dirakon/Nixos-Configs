# TODO: based on https://github.com/gytis-ivaskevicius/nixfiles/blob/4a6dc53cb1eae075d7303ce2b90e02ad850b48fb/config/sway.nix#L7
# ??
self@{ config, pkgs, hypr-pkgs, unstable, ... }:
{
  services.displayManager.sessionPackages = [ hypr-pkgs.sway ];

  imports = [ ./wm-utils.nix ];

  environment.systemPackages = with pkgs; [
    hypr-pkgs.autotiling
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
      export QT_STYLE_OVERRIDE=kvantum
    '';
    extraOptions = [ "--unsupported-gpu" ];
  };

}
