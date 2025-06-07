self@{ config, pkgs, boot, hostname, sensitive, modulesPath, lib, ... }:
{
  environment.etc."ssh/ssh_config".text = ''
    Host sentinel-local
      HostName ${sensitive.sentinel.local-ip}
      Port ${toString sensitive.sentinel.ssh.port}
      User dirakon
    Host sentinel
      HostName ${sensitive.sentinel.ssh.hostname}
      Port ${toString sensitive.sentinel.ssh.port}
      User dirakon
    Host guide
      HostName ${sensitive.guide.ip}
      Port ${toString sensitive.guide.ssh.port}
      User dirakon
    Host guide2
      HostName ${sensitive.guide2.ip}
      Port ${toString sensitive.guide2.ssh.port}
      User dirakon
    Host rat
      HostName 127.0.0.1
      Port ${toString sensitive.rat.ssh.port}
      User dirakon
  '';
}
