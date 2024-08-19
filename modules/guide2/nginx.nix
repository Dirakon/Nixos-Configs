self@{ config, nix, pkgs, boot, stable, hostname, networking, ... }:
let
  certbot-script =
    pkgs.writeShellScriptBin "certbot-script" ''
      domain=$(cat '${config.sops.secrets."guide2/hostname".path}')
      mkdir -p /var/www/demo
      ${pkgs.certbot-full}/bin/certbot certonly --webroot -w /var/www/demo -d $domain --non-interactive
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
