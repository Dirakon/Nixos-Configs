self@{ config, pkgs, boot, stable, hostname, modulesPath, ... }:
{
  sops.defaultSopsFile = ../../secrets/guide2-private.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/dirakon/.config/sops/age/keys.txt";
}
