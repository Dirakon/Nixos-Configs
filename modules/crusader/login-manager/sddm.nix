{ config, pkgs, sensitive, ... }:
{
  environment.systemPackages = with pkgs; [
    (pkgs.callPackage ./sddm-astronaut-theme.nix {
      theme = "hyprland_kath";
      # theme = "pixel_sakura";
      themeConfig = {
        General = {
          # HeaderText = "Hi";
          Background = "${sensitive.crusader.login-background-animated}";
          # FontSize = "10.0";
          HaveFormBackground = "false";
          HideSystemButtons = "false";
          HideVirtualKeyboard = "true";
        };
      };
    })
  ];
  services.displayManager.sddm = {
    wayland.enable = true;
    enable = true;
    package = pkgs.kdePackages.sddm;
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs; [
      kdePackages.qtmultimedia
      kdePackages.qtsvg
      kdePackages.qtvirtualkeyboard
    ];
  };
}
