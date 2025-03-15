self@{ config, pkgs, boot, hostname, sensitive, ... }:
{
  networking.firewall.allowedTCPPorts =
    [
      sensitive.guide2.ssh.port
      sensitive.guide2.awg.port
      sensitive.sentinel.ssh.port
      sensitive.sentinel.firefox-syncserver.port

      80 # nginx
      443 # nginx
      sensitive.sentinel.jellyfin.port
      sensitive.guide2.certbot.port
      sensitive.sentinel.obsidian-couchdb.port
      sensitive.sentinel.suwayomi.port
      sensitive.sentinel.gitea.ssh-port
      sensitive.sentinel.languagetool.port
    ];
  networking.firewall.allowedUDPPorts =
    [
      sensitive.guide2.ssh.port
      sensitive.guide2.awg.port
      sensitive.sentinel.ssh.port

      80 # nginx
      443 # nginx
      sensitive.sentinel.jellyfin.port
      sensitive.guide2.certbot.port
      sensitive.sentinel.obsidian-couchdb.port
      sensitive.sentinel.suwayomi.port
      sensitive.sentinel.gitea.ssh-port
      sensitive.sentinel.languagetool.port
    ];
}
