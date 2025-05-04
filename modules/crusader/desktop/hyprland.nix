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
let
  mkSystemdStartupService = { dependencies ? [ ], systemdDependencies ? [ ], name, script, busName ? "none" }:
    let
      bashScript = pkgs.writeShellScriptBin name script;
    in
    {
      enable = true;
      wantedBy = [ "graphical-session.target" ] ++ systemdDependencies;
      partOf = [ "graphical-session.target" ] ++ systemdDependencies;
      after = [ "graphical-session.target" ] ++ systemdDependencies;
      path = dependencies;
      requisite = [ "graphical-session.target" ] ++ systemdDependencies;
      description = "${name}: autostarted on hyprland start";
      serviceConfig =
        {
          Restart = "on-failure";
          ExecStart = "${bashScript}/bin/${name}";
          RestartSec = 1;
        } // (if busName == "none" then { } else {
          BusName = busName;
        });
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

  systemd.user.services = {
    # swayosd-server already provides systemd
    # waybar already provides systemd
    # blueman-applet already provides systemd
    # nm-applet already provides systemd

    dolphin-daemon = mkSystemdStartupService {
      dependencies = [ pkgs.dolphin ];
      name = "dolphin-daemon";
      script =
        ''
          dolphin --daemon
        '';
      busName = "org.freedesktop.FileManager1";
    };

    battery-monitor = mkSystemdStartupService {
      dependencies = [ pkgs.bash pkgs.fish pkgs.upower pkgs.gawk pkgs.libnotify ];
      name = "battery-monitor";
      script =
        ''
          /home/dirakon/.scripts/battery-monitor.sh
        '';
    };

    swww-daemon = mkSystemdStartupService {
      dependencies = [ pkgs.swww ];
      name = "swww-daemon";
      script =
        ''
          swww-daemon
        '';
    };

    swww-auto = mkSystemdStartupService {
      dependencies = [ pkgs.fish pkgs.bash pkgs.swww ];
      systemdDependencies = [ "swww-daemon.service" ];
      name = "swww-auto";
      script =
        ''
          /home/dirakon/.scripts/swww-auto.sh /home/dirakon/Wallpapers/Final/
        '';
    };

    lxqt-policykit-agent = mkSystemdStartupService {
      dependencies = [ pkgs.lxqt.lxqt-policykit ];
      name = "lxqt-policykit-agent";
      script =
        ''
          lxqt-policykit-agent
        '';
    };
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
