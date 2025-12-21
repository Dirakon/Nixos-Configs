self@{ config, pkgs, boot, hostname, modulesPath, sensitive, ... }:
{
  networking.firewall.allowedTCPPorts =
    [
      sensitive.guide.ssh.port
      sensitive.guide.awg.port
      sensitive.sentinel.ssh.port
      sensitive.sentinel.firefox-syncserver.port

      80 # nginx
      443 # nginx
      22 # ssh just in case

      sensitive.sentinel.jellyfin.port
      sensitive.guide.certbot.port
      sensitive.sentinel.suwayomi.port
      sensitive.sentinel.gitea.ssh-port
      sensitive.sentinel.languagetool.port

      22000 # syncthing
    ];
  networking.firewall.allowedUDPPorts =
    [
      sensitive.guide.ssh.port
      sensitive.guide.awg.port
      sensitive.sentinel.ssh.port

      80 # nginx
      443 # nginx
      22 # ssh just in case

      sensitive.sentinel.jellyfin.port
      sensitive.guide.certbot.port
      sensitive.sentinel.suwayomi.port
      sensitive.sentinel.gitea.ssh-port
      sensitive.sentinel.languagetool.port

      22000 # syncthing 1
      21027 # syncthing 2
    ];
}
