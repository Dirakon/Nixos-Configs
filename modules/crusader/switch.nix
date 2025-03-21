{ config
, pkgs
, hostname
, sensitive
, ...
}:
{
  home-manager.users.dirakon =
    {
      home.file.".config/Ryujinx/system/prod.keys" = {
        source = sensitive.crusader.switch-prod-keys;
      };
      home.file.".local/share/yuzu/keys/prod.keys" = {
        source = sensitive.crusader.switch-prod-keys;
      };
      home.packages = with pkgs; [
        ryujinx
        torzu
        nsz
      ];
    };
}
