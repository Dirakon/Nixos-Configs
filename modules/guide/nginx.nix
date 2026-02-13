self@{ config
, nix
, pkgs
, boot
, sensitive
, hostname
, networking
, ...
}:
let main-domain = sensitive.sentinel.main-domain.domain; in
let
  nginx-config = ''
    worker_processes auto;
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
              ${sensitive.sentinel.nextcloud.hostname} normal;
              ${sensitive.sentinel.gitea.hostname} normal;
              ${sensitive.sentinel.mattermost.hostname} normal;
              ${sensitive.sentinel.suwayomi.hostname} normal;
              ${sensitive.sentinel.languagetool.hostname} normal;
              ${sensitive.sentinel.jellyfin.hostname} normal;
              ${sensitive.sentinel.firefox-syncserver.hostname} normal;
              default xtls;
      }
      upstream xtls {
              server 127.0.0.1:444; # Xray port
      }
      upstream normal {
              server 127.0.0.1:442; # Port for normal (non-xray) https
      }

      server {
          listen 443;
          proxy_pass      $my_stream_domain_router;
          ssl_preread     on;
      }
    }
  '';
  nginx-http-config = ''
    server_names_hash_bucket_size 128;

    # suwayomi
    server {
        listen 442 ssl;
        server_name ${sensitive.sentinel.suwayomi.hostname} www.${sensitive.sentinel.suwayomi.hostname};
          
        ssl_certificate /etc/letsencrypt/live/${main-domain}/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/${main-domain}/privkey.pem;

        location / {
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_http_version 1.1;

          proxy_pass http://${sensitive.sentinel.awg.ip}:${toString sensitive.sentinel.suwayomi.port};
        }
    }

    # nextcloud
    server {
      listen 442 ssl;
      server_name ${sensitive.sentinel.nextcloud.hostname} www.${sensitive.sentinel.nextcloud.hostname};

      ssl_certificate /etc/letsencrypt/live/${main-domain}/fullchain.pem;
      ssl_certificate_key /etc/letsencrypt/live/${main-domain}/privkey.pem;

      location / {
        proxy_pass http://${sensitive.sentinel.awg.ip}/;
        
        proxy_set_header   Host             $host;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header  X-Forwarded-For  $proxy_add_x_forwarded_for;
      }
    }

    # mattermost
    server {
      listen 442 ssl;
      server_name ${sensitive.sentinel.mattermost.hostname} www.${sensitive.sentinel.mattermost.hostname};

      ssl_certificate /etc/letsencrypt/live/${main-domain}/fullchain.pem;
      ssl_certificate_key /etc/letsencrypt/live/${main-domain}/privkey.pem;

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

    # languagetool
    server {
      listen 442 ssl;
      server_name ${sensitive.sentinel.languagetool.hostname} www.${sensitive.sentinel.languagetool.hostname};

      ssl_certificate /etc/letsencrypt/live/${main-domain}/fullchain.pem;
      ssl_certificate_key /etc/letsencrypt/live/${main-domain}/privkey.pem;

      location / {
        allow 127.0.0.1; # nginx to xray to nginx to languagetool, lol
        deny all;

        proxy_pass http://${sensitive.sentinel.awg.ip}:${toString sensitive.sentinel.languagetool.port}/;
        
        proxy_set_header   Host             $host;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header  X-Forwarded-For  $proxy_add_x_forwarded_for;
      }
    }

    # firefox-syncserver
    server {
      listen 442 ssl;
      server_name ${sensitive.sentinel.firefox-syncserver.hostname} www.${sensitive.sentinel.firefox-syncserver.hostname};

      ssl_certificate /etc/letsencrypt/live/${main-domain}/fullchain.pem;
      ssl_certificate_key /etc/letsencrypt/live/${main-domain}/privkey.pem;

      location / {
        allow ${sensitive.guide.ip};
        deny all;
        
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_redirect off;
        proxy_read_timeout 120;
        proxy_connect_timeout 10;

        proxy_pass http://${sensitive.sentinel.awg.ip}:${toString sensitive.sentinel.firefox-syncserver.port}/;
      }
    }

    server {
      listen 442 ssl;
      server_name ${sensitive.sentinel.gitea.hostname} www.${sensitive.sentinel.gitea.hostname};

      ssl_certificate /etc/letsencrypt/live/${main-domain}/fullchain.pem;
      ssl_certificate_key /etc/letsencrypt/live/${main-domain}/privkey.pem;

      location / {
        proxy_pass http://${sensitive.sentinel.awg.ip}:${toString sensitive.sentinel.gitea.http-port}/;
        
        proxy_set_header   Host             $host;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header  X-Forwarded-For  $proxy_add_x_forwarded_for;
      }
    }

    server {
      listen 442 ssl;
      server_name ${sensitive.sentinel.jellyfin.hostname} www.${sensitive.sentinel.jellyfin.hostname};

      ssl_certificate /etc/letsencrypt/live/${main-domain}/fullchain.pem;
      ssl_certificate_key /etc/letsencrypt/live/${main-domain}/privkey.pem;

      location / {
        proxy_pass http://${sensitive.sentinel.awg.ip}:${toString sensitive.sentinel.jellyfin.port}/;
        
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

    eventsConfig = "worker_connections 20480;";
    appendHttpConfig = nginx-http-config;

    appendConfig = nginx-config;
  };
}
