self@{ config, pkgs, boot, stable, hostname, modulesPath, ... }:
{
  networking.firewall.allowedTCPPorts =
    [
      55932
      80
      443
      22
      53
      51871 # wg???
    ];
  networking.firewall.allowedUDPPorts =
    [
      55932
      80
      443
      22
      53
      51871 # wg???
    ];
}
