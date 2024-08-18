self@{ config, pkgs, boot, stable, hostname, modulesPath, ... }:
{
  sops.secrets."guide/ip" = {
    mode = "0444";
    key = "ip";
    sopsFile = ./../../secrets/guide-public.yaml;
  };
  sops.secrets."guide/domain" = {
    mode = "0444";
  };

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
