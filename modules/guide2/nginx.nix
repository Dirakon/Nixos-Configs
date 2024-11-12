self@{ config, nix, pkgs, boot, sensitive, hostname, networking, ... }:
let
  certbot-script =
    pkgs.writeShellScriptBin "certbot-script" ''
      mkdir -p /var/www/demo
      ${pkgs.certbot-full}/bin/certbot certonly --webroot -w /var/www/demo -d ${sensitive.sentinel.nextcloud.hostname} --non-interactive
      sleep 10
      ${pkgs.certbot-full}/bin/certbot certonly --webroot -w /var/www/demo -d ${sensitive.sentinel.gitea.hostname} --non-interactive
      sleep 10
      ${pkgs.certbot-full}/bin/certbot certonly --webroot -w /var/www/demo -d ${sensitive.sentinel.misc.hostname} --non-interactive
      sleep 10
      ${pkgs.certbot-full}/bin/certbot certonly --webroot -w /var/www/demo -d ${sensitive.sentinel.mattermost.hostname} --non-interactive
      chown -R nginx:acme /etc/letsencrypt/ # nginx..
      chmod 755 /etc/letsencrypt/ # nginx...
    '';
  nginx-config = ''
    stream {
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

      upstream couchdb_proxy {
          server ${sensitive.sentinel.awg.ip}:${toString sensitive.sentinel.obsidian-couchdb.port};
      }

      server {
          listen ${toString sensitive.sentinel.obsidian-couchdb.port} ssl;
            
          ssl_certificate /etc/letsencrypt/live/${sensitive.sentinel.obsidian-couchdb.hostname}/fullchain.pem;
          ssl_certificate_key /etc/letsencrypt/live/${sensitive.sentinel.obsidian-couchdb.hostname}/privkey.pem;

          proxy_pass couchdb_proxy;
      }

      upstream suwayomi_proxy {
          server ${sensitive.sentinel.awg.ip}:${toString sensitive.sentinel.suwayomi.port};
      }

      server {
          listen ${toString sensitive.sentinel.suwayomi.port} ssl;
            
          ssl_certificate /etc/letsencrypt/live/${sensitive.sentinel.suwayomi.hostname}/fullchain.pem;
          ssl_certificate_key /etc/letsencrypt/live/${sensitive.sentinel.suwayomi.hostname}/privkey.pem;

          proxy_pass suwayomi_proxy;
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

    server {
      listen 443 ssl;
      server_name ${sensitive.sentinel.nextcloud.hostname} www.${sensitive.sentinel.nextcloud.hostname};

      ssl_certificate /etc/letsencrypt/live/${sensitive.sentinel.nextcloud.hostname}/fullchain.pem;
      ssl_certificate_key /etc/letsencrypt/live/${sensitive.sentinel.nextcloud.hostname}/privkey.pem;

      location / {
        proxy_pass http://${sensitive.sentinel.awg.ip}/;
        
        proxy_set_header   Host             $host;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header  X-Forwarded-For  $proxy_add_x_forwarded_for;
      }
    }

    server {
      listen 443 ssl;
      server_name ${sensitive.sentinel.mattermost.hostname} www.${sensitive.sentinel.mattermost.hostname};

      ssl_certificate /etc/letsencrypt/live/${sensitive.sentinel.mattermost.hostname}/fullchain.pem;
      ssl_certificate_key /etc/letsencrypt/live/${sensitive.sentinel.mattermost.hostname}/privkey.pem;

      location ~ /api/v[0-9]+/(users/)?websocket$ {
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        client_max_body_size 50M;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Frame-Options SAMEORIGIN;
        proxy_buffers 256 16k;
        proxy_buffer_size 16k;
        client_body_timeout 60s;
        send_timeout 300s;
        lingering_timeout 5s;
        proxy_connect_timeout 90s;
        proxy_send_timeout 300s;
        proxy_read_timeout 90s;
        proxy_http_version 1.1;

        proxy_pass http://${sensitive.sentinel.awg.ip}:${toString sensitive.sentinel.mattermost.port};
      }

      location / {
        client_max_body_size 100M;
        proxy_set_header Connection "";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Frame-Options SAMEORIGIN;
        proxy_buffers 256 16k;
        proxy_buffer_size 16k;
        proxy_read_timeout 600s;
        proxy_http_version 1.1;

        proxy_pass http://${sensitive.sentinel.awg.ip}:${toString sensitive.sentinel.mattermost.port};
      }
    }

    server {
      listen ${toString sensitive.sentinel.languagetool.port} ssl;
      server_name ${sensitive.sentinel.languagetool.hostname} www.${sensitive.sentinel.languagetool.hostname};

      ssl_certificate /etc/letsencrypt/live/${sensitive.sentinel.languagetool.hostname}/fullchain.pem;
      ssl_certificate_key /etc/letsencrypt/live/${sensitive.sentinel.languagetool.hostname}/privkey.pem;

      location / {
        allow ${sensitive.guide.ip};
        deny all;

        proxy_pass http://${sensitive.sentinel.awg.ip}:${toString sensitive.sentinel.languagetool.port}/;
        
        proxy_set_header   Host             $host;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header  X-Forwarded-For  $proxy_add_x_forwarded_for;
      }
    }

    server {
      listen 443 ssl;
      server_name ${sensitive.sentinel.gitea.hostname} www.${sensitive.sentinel.gitea.hostname};

      ssl_certificate /etc/letsencrypt/live/${sensitive.sentinel.gitea.hostname}/fullchain.pem;
      ssl_certificate_key /etc/letsencrypt/live/${sensitive.sentinel.gitea.hostname}/privkey.pem;

      location / {
        proxy_pass http://${sensitive.sentinel.awg.ip}:${toString sensitive.sentinel.gitea.http-port}/;
        
        proxy_set_header   Host             $host;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header  X-Forwarded-For  $proxy_add_x_forwarded_for;
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
