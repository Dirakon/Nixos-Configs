self@{ config
, pkgs
, boot
, godot
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
  ];

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
}
