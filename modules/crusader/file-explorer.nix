self@{ config
, pkgs
, boot
, sensitive
, unstable
, ...
}:
{
  environment.systemPackages = with pkgs; [
    kdePackages.dolphin
    kdePackages.konsole # For dolphin integrated term

    kdePackages.dolphin-plugins
    kdePackages.kio-admin
    kdePackages.kio
    kdePackages.kio-extras
    kdePackages.kio-fuse

    kdePackages.kdegraphics-thumbnailers
    kdePackages.ffmpegthumbs # shold thumbnail videos but not working ...
    # kdePackages.kdegraphics-thumbnailers # For some reason only qt5 ver works

    kdePackages.breeze-icons
    # kdePackages.qtscxml
    # libsForQt5.qt5.qtscxml
  ];

  home-manager.users.dirakon =
    {
      xdg.mimeApps.defaultApplications."inode/directory" = "org.kde.dolphin.desktop";
    };
}
