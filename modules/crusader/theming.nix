inputs@{ config
, pkgs
, hostname
, sensitive
, ...
}:
{
  stylix = {
    enable = true;
    polarity = "dark";
    autoEnable = true;
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    # Why is this option mandatory...
    image = sensitive.crusader.login-background;
  };

  home-manager.users.dirakon.stylix =
    {
      # iconTheme = {
      #   enable = true;
      #   package = pkgs.papirus-icon-theme.override { color = "indigo"; };
      #   dark = "Papirus-Dark"; # used
      #   light = "Papirus-Light"; # unused
      # };
      # iconTheme = {
      #   enable = true;
      #   package = pkgs.kdePackages.breeze-icons;
      #   light = "breeze";
      #   dark = "breeze-dark";
      # };
      iconTheme = {
        enable = true;
        package = pkgs.fluent-icon-theme;
        dark = "Fluent-dark";
        light = "Fluent";
      };
      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Original-Classic";
        size = 22;
      };
    };

  environment.systemPackages = with pkgs; [
    # QT (cleanup!)
    kdePackages.breeze-icons
    # kdePackages.qtscxml
    # libsForQt5.qt5.qtscxml
  ];


  # TODO: also migrate to stylix on 25.05
  environment.sessionVariables.QT_QPA_PLATFORMTHEME = "qt5ct";
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
    };
}
