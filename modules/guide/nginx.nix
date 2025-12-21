self@{ config, nix, pkgs, boot, sensitive, hostname, networking, ... }:
let
  certbot-script =
    pkgs.writeShellScriptBin "certbot-script" ''
      mkdir -p /var/www/demo
      ${pkgs.certbot}/bin/certbot certonly --webroot -w /var/www/demo -d ${sensitive.sentinel.nextcloud.hostname} --non-interactive
      sleep 10
      ${pkgs.certbot}/bin/certbot certonly --webroot -w /var/www/demo -d ${sensitive.sentinel.gitea.hostname} --non-interactive
      sleep 10
      ${pkgs.certbot}/bin/certbot certonly --webroot -w /var/www/demo -d ${sensitive.sentinel.misc.hostname} --non-interactive
      sleep 10
      ${pkgs.certbot}/bin/certbot certonly --webroot -w /var/www/demo -d ${sensitive.sentinel.mattermost.hostname} --non-interactive
      chown -R nginx:acme /etc/letsencrypt/ # nginx..
      chmod 755 /etc/letsencrypt/ # nginx...
    '';
  nginx-config = ''
    stream {
      map_hash_max_size 128;
      map_hash_bucket_size 128;

      upstream syncthing_proxy_1 {
          server ${sensitive.sentinel.awg.ip}:22000;
      }

      server {
          listen 22000;
          proxy_pass syncthing_proxy_1;
      }

      server {
          listen 22000 udp;
          proxy_pass syncthing_proxy_1;
          proxy_responses 0;
      }

      upstream syncthing_proxy_2 {
          server ${sensitive.sentinel.awg.ip}:21027;
      }

      server {
          listen 21027;
          proxy_pass syncthing_proxy_2;
      }

      upstream ssh_proxy {
          server ${sensitive.sentinel.awg.ip}:${toString sensitive.sentinel.ssh.port};
      }

      server {
          listen ${toString sensitive.sentinel.ssh.port};
          proxy_pass ssh_proxy;
      }

      upstream ssh_proxy_gitea {
          server ${sensitive.sentinel.awg.ip}:${toString sensitive.sentinel.gitea.ssh-port};
      }

      server {
          listen ${toString sensitive.sentinel.gitea.ssh-port};
          server_name ${sensitive.sentinel.gitea.hostname} www.${sensitive.sentinel.gitea.hostname};
          proxy_pass ssh_proxy_gitea;
      }

      map $ssl_preread_server_name $my_stream_domain_router {
              ${sensitive.sentinel.nextcloud.hostname} nextcloud;
              ${sensitive.sentinel.gitea.hostname} git;
              ${sensitive.sentinel.mattermost.hostname} chat;
              default xtls;
      }
      upstream xtls {
              server 127.0.0.1:444; # Xray port
      }
      upstream nextcloud {
              server 127.0.0.1:442; # Nextcloud port
      }
      upstream git {
              server 127.0.0.1:442; # Git port
      }
      upstream chat {
              server 127.0.0.1:442; # Chat port
      }

      server {
          listen 443;
          proxy_pass      $my_stream_domain_router;
          ssl_preread     on;
      }
    }
  '';
  nginx-http-config = ''
    server {
      listen 80;
      location '/.well-known/acme-challenge' {
          root /var/www/demo;
      }
    }
  '';
in
{
  users.extraGroups."acme".members = [ "nginx" ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    appendHttpConfig = nginx-http-config;

    appendConfig = nginx-config;
  };

  # certbot renew -- based on https://github.com/qsdrqs/mydotfiles/blob/5282bd45cd80fafc81d7ec647d821253b25681e8/nixos/server-configuration.nix#L32
  systemd.services.certbot-renew = {
    enable = true;
    description = "Certbot Renewal";
    serviceConfig = {
      ExecStart = "${certbot-script}/bin/certbot-script";
      Restart = "on-failure";
      RestartSec = 5;
    };
    after = [ "sops-nix.service" "network.target" ];
    wantedBy = [ "sops-nix.service" "multi-user.target" ];
  };
  systemd.timers.certbot-renew = {
    enable = config.systemd.services.certbot-renew.enable;
    description = "Daily renewal of Let's Encrypt's certificates by certbot";
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };
}
