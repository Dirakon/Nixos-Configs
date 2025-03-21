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
    dolphin
    konsole # For dolphin integrated term

    kdePackages.dolphin-plugins
    libsForQt5.dolphin-plugins

    libsForQt5.kio
    libsForQt5.kio-extras
    libsForQt5.kio-admin

    kio-admin
    kio-fuse

    kdePackages.kio
    kdePackages.kio-extras
    kdePackages.kio-fuse

    libsForQt5.kdegraphics-thumbnailers
    libsForQt5.ffmpegthumbs # shold thumbnail videos but not working ...
    kdePackages.ffmpegthumbs # shold thumbnail videos but not working ...
    # kdePackages.kdegraphics-thumbnailers # For some reason only qt5 ver works

    kdePackages.breeze-icons
    # kdePackages.qtscxml
    # libsForQt5.qt5.qtscxml
  ];

  home-manager.users.dirakon =
    {
      xdg.mimeApps.defaultApplications."inode/directory" = "dolphin.desktop";
    };
}
