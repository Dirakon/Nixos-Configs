self@{ config
, pkgs
, hypr-pkgs
, my-utils
, ...
}:
let
  hypr-exit-session = pkgs.writeShellApplication {
    name = "hypr-exit-session";
    runtimeInputs = [
      pkgs.libnotify
      pkgs.procps
      hypr-pkgs.uwsm
    ];
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

  environment.systemPackages = with hypr-pkgs; [
    hyprshot
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
    # blueman-applet already provides systemd
    # nm-applet already provides systemd

    # waybar already provides systemd, but we need to give it some dependencies:
    waybar = {
      path = [
        hypr-pkgs.uwsm
        pkgs.gawk
        pkgs.dualsensectl
        pkgs.bash
        pkgs.fish
        pkgs.kitty
        pkgs.btop
        pkgs.pavucontrol
        pkgs.jc
        pkgs.jq
        pkgs.upower
      ];
    };

    # Based on https://github.com/KDE/dolphin/blob/master/plasma-dolphin.service.in
    dolphin-daemon = my-utils.mkSystemdStartupService pkgs {
      dependencies = [ pkgs.kdePackages.dolphin ];
      name = "dolphin-daemon";
      script = ''
        dolphin --daemon
      '';
      busName = "org.freedesktop.FileManager1";
    };

    battery-monitor = my-utils.mkSystemdStartupService pkgs {
      dependencies = [
        pkgs.bash
        pkgs.fish
        pkgs.upower
        pkgs.gawk
        pkgs.libnotify
      ];
      name = "battery-monitor";
      script = ''
        /home/dirakon/.scripts/battery-monitor.sh
      '';
    };

    swww-daemon = my-utils.mkSystemdStartupService pkgs {
      dependencies = [ pkgs.swww ];
      name = "swww-daemon";
      script = ''
        swww-daemon
      '';
    };

    swww-auto = my-utils.mkSystemdStartupService pkgs {
      dependencies = [
        pkgs.fish
        pkgs.bash
        pkgs.swww
      ];
      systemdDependencies = [ "swww-daemon.service" ];
      name = "swww-auto";
      script = ''
        /home/dirakon/.scripts/swww-auto.sh /home/dirakon/Wallpapers/Final/
      '';
    };

    lxqt-policykit-agent = my-utils.mkSystemdStartupService pkgs {
      dependencies = [ pkgs.lxqt.lxqt-policykit ];
      name = "lxqt-policykit-agent";
      script = ''
        lxqt-policykit-agent
      '';
    };
  };

  programs.uwsm = {
    enable = true;
    package = hypr-pkgs.uwsm;
  };

  # Run XDG autostart, this is needed for a DE-less setup like Hyprland
  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
