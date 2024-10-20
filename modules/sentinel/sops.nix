self@{ config, pkgs, boot, hostname, modulesPath, sensitive, ... }:
{
  sops.defaultSopsFile = sensitive.sentinel.secrets;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/dirakon/.config/sops/age/keys.txt";
}
