self@{ config
, pkgs
, boot
, ultim-mc
, sensitive
, unstable
, ...
}:
{
  environment.systemPackages = with pkgs; [
    lutris
    unstable.umu-launcher # TODO: make stable when its there
    rpcs3
    ultim-mc

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

    antimicrox # gamepad to keyboards GUI (non-declarative)
  ];

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "dirakon" ];

  # https://github.com/NixOS/nixpkgs/issues/363887#issuecomment-2536693220
  boot.kernelParams = [ "kvm.enable_virt_at_load=0" ];

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;


  # Udev rules for joystick deadzones
  # https://wiki.archlinux.org/title/Gamepad
  services.udev.extraRules = ''
    ACTION=="add", KERNEL=="js[0-9]*", ATTRS{uniq}=="90:b6:85:3a:e0:4f", RUN+="${pkgs.linuxConsoleTools}/bin/jscal -s 8,1,0,128,128,4194176,4227201,1,0,98,158,5478107,5534582,1,0,127,127,4227201,4194176,1,0,129,129,4161663,4260750,1,0,126,126,4260750,4161663,1,0,127,127,4227201,4194176,1,0,0,0,536854528,536854528,1,0,0,0,536854528,536854528 /dev/input/js%n"
  '';
}
