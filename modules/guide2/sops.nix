self@{ config, pkgs, boot, hostname, modulesPath, sensitive, ... }:
{
  sops.defaultSopsFile = sensitive.guide2.secrets;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/dirakon/.config/sops/age/keys.txt";
}
