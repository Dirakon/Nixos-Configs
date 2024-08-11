self@{ config, pkgs, boot, stable, hostname, modulesPath, ... }:
{
  # sops.secrets."guide2/ip" = {
  #   mode = "0444";
  # };
  # sops.secrets."guide2/domain" = {
  #   mode = "0444";
  # };

  networking.firewall.allowedTCPPorts =
    [
      55932
      80
      443
      22
    ];
  networking.firewall.allowedUDPPorts =
    [
      55932
      80
      443
      22
    ];
}
