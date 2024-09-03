self@{ config, pkgs, boot, hostname, ... }:
{
  environment.etc."nextcloud-admin-pass".text = "PWD";
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    hostName = "localhost";
    config.adminpassFile = "/etc/nextcloud-admin-pass";
  };
}
