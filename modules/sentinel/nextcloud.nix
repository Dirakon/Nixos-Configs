self@{ config, pkgs, boot, hostname, sensitive, ... }:
{
  sops.secrets."nextcloud/password" = {
    # TODO: move secrets to sensitive repo (why not?)
    # Then would be like `sopsFile = sensitive.sentinel.secrets`
    # 'public' part would become just sensitive strings
    sopsFile = ./../../secrets/sentinel-private.yaml;
    mode = "0444";
    key = "nextcloud/password";
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud29;
    hostName = sensitive.sentinel.nextcloud.hostname;
    config.adminpassFile = config.sops.secrets."nextcloud/password".path;
    https = true;
  };
}
