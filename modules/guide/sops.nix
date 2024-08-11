self@{ config, pkgs, boot, stable, hostname, modulesPath, ... }:
{
  sops.defaultSopsFile = ../../secrets/secrets-guide.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/dirakon/.config/sops/age/keys.txt";
}
