inputs@{ config
, pkgs
, hostname
, sensitive
, ...
}:
{
  stylix.enable = true;
  stylix.polarity = "dark";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  # Why is this option mandatory...
  stylix.image = sensitive.crusader.login-background;

  home-manager.users.dirakon =
    {
      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style = {
          name = "kvantum";
        };
      };

      home.packages = with pkgs; [
        libsForQt5.qt5ct
      ];

      gtk = {
        iconTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };
      };
    };
}
