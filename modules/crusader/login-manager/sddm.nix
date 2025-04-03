{ config, pkgs, sensitive, ... }:
let
  user-icon-setter-script = pkgs.writeShellScriptBin "user-icon-setter-script" ''
    cp -f "${sensitive.crusader.user-icon}" "/var/lib/AccountsService/icons/dirakon"
  '';
in
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


  # Define systemd service to run script on boot
  systemd.services.icon-setter = {
    description = "Script to copy or update users Avatars at startup.";
    wantedBy = [ "multi-user.target" ];
    before = [ "sddm.service" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${user-icon-setter-script}/bin/user-icon-setter-script";
      StandardOutput = "journal+console";
      StandardError = "journal+console";
    };
  };

  # Ensures SDDM starts after the service.
  systemd.services.sddm = {
    after = [ "icon-setter.service" ];
  };
}
