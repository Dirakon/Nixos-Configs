self@{ config, pkgs, boot, hostname, modulesPath, sensitive, ... }:
{
  networking.firewall.allowedTCPPorts =
    [
      sensitive.guide.ssh.port
      80
      443
      22
    ];
  networking.firewall.allowedUDPPorts =
    [
      sensitive.guide.ssh.port
      80
      443
      22
    ];
}
