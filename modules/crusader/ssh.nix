self@{ config, pkgs, boot, stable, hostname, modulesPath, lib, ... }:
{
  # sops.defaultSopsFile = ../../secrets/guide-private.yaml;
  # Into separate sops file if needed?
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/dirakon/.config/sops/age/keys.txt";

  sops.secrets."guide2/ip" = {
    sopsFile = ./../../secrets/guide2-public.yaml;
    mode = "0444";
    key = "ip";
  };
  sops.secrets."guide/ip" = {
    sopsFile = ./../../secrets/guide-public.yaml;
    mode = "0444";
    key = "ip";
  };
  sops.secrets."sentinel/ip" = {
    sopsFile = ./../../secrets/sentinel-public.yaml;
    mode = "0444";
    key = "ip";
  };

  sops.templates."ssh.conf" = {
    mode = "0444";
    content = ''
      Host sentinel
        HostName ${config.sops.placeholder."sentinel/ip"}
        Port 55932
        User dirakon
      Host guide
        HostName ${config.sops.placeholder."guide/ip"}
        Port 55932
        User dirakon
      Host guide2
        HostName ${config.sops.placeholder."guide2/ip"}
        Port 55932
        User dirakon
    '';
  };

  environment.etc."ssh/ssh_config".source = lib.mkForce "${config.sops.templates."ssh.conf".path}";
}
