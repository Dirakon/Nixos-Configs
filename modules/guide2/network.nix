self@{ config, pkgs, boot, hostname, modulesPath, ... }:
{
  networking.firewall.allowedTCPPorts =
    [
      55932
      80
      443
      22
      51871 # wg???
      55933 # ssh proxying for sentinel
      55934 # certbot
      54932 # couchdb for obs
    ];
  networking.firewall.allowedUDPPorts =
    [
      55932
      80
      443
      22
      51871 # wg???
      55933 # ssh proxying for sentinel
      55934 # certbot
      54932 # couchdb for obs
    ];
}
