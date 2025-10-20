self@{ config
, pkgs
, boot
, sensitive
, unstable
, my-utils
, ...
}:
{
  environment.systemPackages = with pkgs; [
    lutris
    umu-launcher
    rpcs3
    easyrpg-player
    dolphin-emu

    # Wine
    # wine # https://nixos.wiki/wiki/Wine
    wineWowPackages.full
    dxvk
    mesa
    wineWowPackages.fonts
    winetricks
    gst_all_1.gstreamer
    gst_all_1.gst-vaapi
    gst_all_1.gst-libav
    gst_all_1.gstreamermm
    gst_all_1.gst-plugins-rs
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly

    # Further gaming
    jstest-gtk
    joystickwake
    linuxConsoleTools
    sc-controller # thing to create virtual xbox controller! Very cool.

    antimicrox # gamepad to keyboards GUI (non-declarative)
  ];

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "dirakon" ];

  # https://github.com/NixOS/nixpkgs/issues/363887#issuecomment-2536693220
  boot.kernelParams = [ "kvm.enable_virt_at_load=0" ];

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  services.flatpak = {
    packages = [
      "flathub:app/com.discordapp.Discord/x86_64/stable"
      "flathub:app/com.usebottles.bottles/x86_64/stable"
    ];
    overrides = {
      "com.usebottles.bottles" = {
        Context.filesystems = [
          "/home/dirakon/Games"
          "/mnt/arch/home/dirakon/Games"
          "/media/"
          "/run/media/"
        ];
      };
    };
  };

  # Udev rules for joystick deadzones
  # https://wiki.archlinux.org/title/Gamepad
  # Also from here: https://github.com/Banh-Canh/ds4drv/blob/master/udev/50-ds4drv.rules
  services.udev = {
    extraRules = ''
      ACTION=="add", KERNEL=="js[0-9]*", ATTRS{uniq}=="90:b6:85:3a:e0:4f", RUN+="${pkgs.linuxConsoleTools}/bin/jscal -s 8,1,0,128,128,4194176,4227201,1,0,98,158,5478107,5534582,1,0,127,127,4227201,4194176,1,0,129,129,4161663,4260750,1,0,126,126,4260750,4161663,1,0,127,127,4227201,4194176,1,0,0,0,536854528,536854528,1,0,0,0,536854528,536854528 /dev/input/js%n"
      KERNEL=="uinput", MODE="0666"
      KERNEL=="event*", MODE="0666"
    '';
    packages = with pkgs; [
      game-devices-udev-rules
    ];
  };

  # TODO: sometimes doesn't work? also fails on restart?
  # systemd.user.services = {
  #   sc-controller-daemon = my-utils.mkSystemdStartupService pkgs {
  #     dependencies = [ pkgs.sc-controller ];
  #     name = "sc-controller-daemon";
  #     script =
  #       ''
  #         scc-daemon --alone --once start
  #       '';
  #     # They use UNIX double forking for some reason, we have to cope with that...
  #     type = "forking";
  #   };
  # };

  hardware = {
    uinput.enable = true;
    enableAllFirmware = true;
  };
  boot = {
    kernelModules = [
      "uinput"
      "usbhid"
    ];
  };
}
