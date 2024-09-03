# TODO: based on https://github.com/gytis-ivaskevicius/nixfiles/blob/4a6dc53cb1eae075d7303ce2b90e02ad850b48fb/config/sway.nix#L7
# ??
self@{ config, lib, pkgs, hypr-pkgs, ... }:
# let
#   wlroots-overlay = final: prev:
#     {
#       wlroots_0_18 = really-unstable.wlroots_0_18;
#       linuxPackages-xanmod = (final.linuxPackagesFor final.linux-xanmod).extend (
#         final: _prev: { ryzen_smu = final.callPackage ./ryzen_smu.nix { }; }
#       );
#       sway-unwrapped = prev.sway-unwrapped.overrideAttrs (attrs: {
#         version = "0-unstable-2024-08-11";
#         src = final.fetchFromGitHub {
#           owner = "swaywm";
#           repo = "sway";
#           rev = "b44015578a3d53cdd9436850202d4405696c1f52";
#           hash = "sha256-gTsZWtvyEMMgR4vj7Ef+nb+wcXkwGivGfnhnBIfPHOA=";
#         };
#         buildInputs = attrs.buildInputs ++ [ final.wlroots ];
#         mesonFlags =
#           let
#             inherit (lib.strings) mesonEnable mesonOption;
#           in
#           [
#             (mesonOption "sd-bus-provider" "libsystemd")
#             (mesonEnable "tray" attrs.trayEnabled)
#           ];
#       });
#       wayland = really-unstable.wayland;
#       wayland-protocols = really-unstable.wayland-protocols;
#       wlroots = prev.wlroots.overrideAttrs (_attrs: {
#         version = "0-unstable-2024-08-11";
#         src = final.fetchFromGitLab {
#           domain = "gitlab.freedesktop.org";
#           owner = "wlroots";
#           repo = "wlroots";
#           rev = "6214144735b6b85fa1e191be3afe33d6bea0faee";
#           hash = "sha256-nuG2xXLDFsGh23CnhaTtdOshCBN/yILqKCSmqJ53vgI=";
#         };
#       });
#     };
# in
{
  # Try fix nvidia flickering - https://discourse.nixos.org/t/screen-flickering-and-tearing-with-nixos-sway-nvidia/49469/6
  # nixpkgs.overlays = [ wlroots-overlay ];
  # Couldn't make it build on stable :(

  services.displayManager.sessionPackages = [ pkgs.sway ];

  imports = [ ./wm-utils.nix ];

  environment.systemPackages = with pkgs; [
    autotiling
    # swayhide # works like 5% of the time at most???
    i3-swallow # <- this works better
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

  environment.sessionVariables = {
    # WLR_RENDERER = "vulkan";
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
