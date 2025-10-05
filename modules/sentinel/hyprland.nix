self@{ config, pkgs, boot, hostname, sensitive, lib, mattermost-youtube-bot, my-utils, ... }:
let
  handle-monitor-replug = pkgs.writeShellScriptBin "handle-monitor-replug" ''
    sleep 7
    # Check if any monitors are connected
    if output=$(cat /sys/class/drm/card*/*HDMI*/status |grep '^connected'); then
      sleep 3
      ydotool mousemove -x 0 -y 0 -a
      sleep 3
      ydotool mousemove -x 0 -y 0 -a
    else
      uwsm stop
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
      dependencies = [ mattermost-youtube-bot pkgs.ydotool pkgs.mpv pkgs.hyprland pkgs.firefox pkgs.uwsm pkgs.procps ];
      name = "youtube-mattermost-bot";
      script =
        ''
          token=`cat ${config.sops.secrets."sentinel/mattermost/youtube-bot-token".path}`

          mattermost-youtube-bot \
            "https://${sensitive.sentinel.mattermost.hostname}" \
            "Home" \
            "$token" \
            -s "uwsm app -- firefox --marionette" \
            -c "uwsm app -- mpv --http-proxy=http://127.0.0.1:20808"
        '';
    };
  };

  # Optional, hint Electron apps to use Wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Monitor hotplugging (attempt 2)
  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="drm", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}="handle-monitor-replug"
  '';
  systemd.user.services."handle-monitor-replug" = {
    description = "Ensure firefox is properly focused even through hyprland weirdness when replugging monitors";
    path = [ pkgs.ydotool pkgs.hyprland pkgs.wlr-randr pkgs.uwsm ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${handle-monitor-replug}/bin/handle-monitor-replug";
    };
    after = [ "graphical-session.target" ];
  };
}
