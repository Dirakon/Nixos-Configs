self@{ config, pkgs, boot, hostname, modulesPath, ... }:
{
  sops.defaultSopsFile = ../../secrets/guide-private.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/dirakon/.config/sops/age/keys.txt";
}
