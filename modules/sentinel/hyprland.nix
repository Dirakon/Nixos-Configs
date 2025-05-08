self@{ config, pkgs, boot, hostname, sensitive, lib, ... }:
{
  # in fish default config we login to hyprland when on tty1
  systemd.services."getty@tty1" = {
    overrideStrategy = "asDropin";
    serviceConfig.ExecStart = [ "" "@${pkgs.util-linux}/sbin/agetty agetty --login-program ${config.services.getty.loginProgram} --autologin dirakon --noclear --keep-baud %I 115200,38400,9600 $TERM" ];
  };

  programs.hyprland = {
    enable = true; # enable Hyprland
    withUWSM = true;
  };

  environment.systemPackages = [
    # For debugging only!
    pkgs.alacritty
    pkgs.pavucontrol
  ];

  programs.firefox.enable = true;

  programs.uwsm = {
    enable = true;
    package = pkgs.uwsm;
  };

  # Optional, hint Electron apps to use Wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
