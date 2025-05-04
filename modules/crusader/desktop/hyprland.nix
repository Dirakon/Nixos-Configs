self@{ config, pkgs, hypr-pkgs, hyprland-qtutils, ... }:
let
  uwsm-starter-script = pkgs.writers.writeBashBin "uwsm-hypr" ''
    ${pkgs.uwsm}/bin/uwsm start "/run/current-system/sw/bin/Hyprland"
  '';
in
let
  custom-uwsm-desktop-session = pkgs.writeText "newhypr.desktop" ''
    [Desktop Entry]
    Name=Newhypr
    Comment=uwsm-managed hypr
    Exec=${uwsm-starter-script}/bin/uwsm-hypr
    Type=Application
  '';
in
let
  uwsm-session-package =
    pkgs.stdenv.mkDerivation {
      pname = "custom-hyprland-uswm-desktop-entry";
      version = "1.0.0";

      phases = [ "unpackPhase" "installPhase" ];

      passthru.providedSessions = [ "newhypr" ];

      dontUnpack = true;

      installPhase = ''
        # Create the directory structure
        mkdir -p $out/share/wayland-sessions
        
        # Create a sample file
        cat ${custom-uwsm-desktop-session} > $out/share/wayland-sessions/newhypr.desktop
      '';
    };
in
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
{
  services.displayManager.sessionPackages = [
    # hypr-pkgs.hyprland

    # I have no clue why default built-in uwsm doesn't work, but THIS works perfectly? 
    # I mean am I not doing the ONLY way to use uwsm?
    # What could built-in uwsm-hypr integration be doing differently?
    uwsm-session-package
  ];

  imports = [ ./wm-utils.nix ];

  environment.systemPackages = with hypr-pkgs; [
    hyprshot
    hyprland-qtutils.default
    hypr-pkgs.uwsm # <- temp for playing around
    hypr-exit-session
  ];

  security.pam.services.hyprlock = { };

  programs.hyprland = {
    enable = true;
    package = hypr-pkgs.hyprland;
    xwayland.enable = true;
    withUWSM = true;
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
