self@{ config, nix, pkgs, boot, hostname, networking, ... }:
let
  certbot-script =
    pkgs.writeShellScriptBin "certbot-script" ''
      domain=$(cat '${config.sops.secrets."guide2/hostname".path}')
      mkdir -p /var/www/demo
      ${pkgs.certbot-full}/bin/certbot certonly --webroot -w /var/www/demo -d $domain --non-interactive
      chown -R nginx:acme /etc/letsencrypt/ # nginx..
      chmod 755 /etc/letsencrypt/ # nginx...
    '';
in
{
  sops.secrets."guide2/hostname" = {
    sopsFile = ./../../secrets/guide2-public.yaml;
    mode = "0444";
    key = "hostname";
  };

  sops.templates."nginx.conf" = {
    mode = "0444";
    content = ''
      stream {
        upstream ssh_proxy {
            server 10.0.0.2:55932;
        }

        server {
            listen 55933;
            proxy_pass ssh_proxy;
        }

        upstream couchdb_proxy {
            server 10.0.0.2:54932;
        }

        server {
            listen 54932 ssl;
            
            ssl_certificate /etc/letsencrypt/live/${config.sops.placeholder."guide2/hostname"}/fullchain.pem;
            ssl_certificate_key /etc/letsencrypt/live/${config.sops.placeholder."guide2/hostname"}/privkey.pem;

            proxy_pass couchdb_proxy;
        }
      }
    '';
  };

  sops.templates."http-nginx.conf" = {
    mode = "0444";
    content = ''
      server {
        listen 80;
        location '/.well-known/acme-challenge' {
            root /var/www/demo;
        }
      }
    '';
  };

  users.extraGroups."acme".members = [ "nginx" ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    appendHttpConfig = ''
      include "${config.sops.templates."http-nginx.conf".path}";
    '';


    appendConfig = ''
      include "${config.sops.templates."nginx.conf".path}";
    '';
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
