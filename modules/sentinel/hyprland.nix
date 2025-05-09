self@{ config, pkgs, boot, hostname, sensitive, lib, mattermost-youtube-bot, my-utils, ... }:
let
  ensure-firefox-focus = pkgs.writeShellScriptBin "ensure-firefox-focus" ''
    sleep 7
    # Check if any monitors are connected
    if output=$(cat /sys/class/drm/card*/*HDMI*/status |grep '^connected'); then
      hyprctl dispatch focuswindow irefox
      sleep 3
      ydotool mousemove -x 0 -y 0 -a
      hyprctl dispatch focuswindow irefox
      sleep 3
      ydotool mousemove -x 0 -y 0 -a
    fi
  '';
in
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

  programs.ydotool = {
    enable = true;
    group = "ydotool";
  };

  users.users.dirakon = {
    extraGroups = [ "ydotool" ];
  };

  environment.systemPackages = [
    # Only start hypr when monitors are connected
    pkgs.wlr-randr

    # For debugging only!
    pkgs.alacritty
    pkgs.pavucontrol
  ];

  programs.firefox.enable = true;

  programs.uwsm = {
    enable = true;
    package = pkgs.uwsm;
  };

  sops.secrets."sentinel/mattermost/youtube-bot-token" = {
    sopsFile = sensitive.sentinel.secrets;
    mode = "0444";
    key = "mattermost/youtube-bot-token";
  };

  systemd.user.services = {
    youtube-mattermost-bot = my-utils.mkSystemdStartupService pkgs {
      dependencies = [ mattermost-youtube-bot ];
      name = "youtube-mattermost-bot";
      script =
        ''
          token=`cat ${config.sops.secrets."sentinel/mattermost/youtube-bot-token".path}`

          mattermost-youtube-bot \
            "https://${sensitive.sentinel.mattermost.hostname}" \
            "Home" \
            "$token"
        '';
    };
  };

  # Optional, hint Electron apps to use Wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Monitor hotplugging (attempt 2)
  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="drm", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}="ensure-firefox-focus"
  '';
  systemd.user.services."ensure-firefox-focus" = {
    description = "Ensure firefox is properly focused even through hyprland weirdness when replugging monitors";
    path = [ pkgs.ydotool pkgs.hyprland pkgs.wlr-randr ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${ensure-firefox-focus}/bin/ensure-firefox-focus";
    };
    after = [ "graphical-session.target" ];
  };
}
