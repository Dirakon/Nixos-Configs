self@{ config
, nix
, pkgs
, boot
, sensitive
, hostname
, networking
, ...
}:
let
  timeweb-auth-script = pkgs.writeShellScriptBin "timeweb-auth-script" (
    builtins.replaceStrings
      [ "<<ROOT_DOMAIN>>" "<<DNS_RECORD_ID>>" ]
      [
        sensitive.sentinel.main-domain.domain
        sensitive.sentinel.main-domain.dns-acme-challenge-txt-record-id
      ]
      (builtins.readFile ./timeweb-auth.sh)
  );
in
let
  certbot-script = pkgs.writeShellScriptBin "certbot-script" ''
    mkdir -p /var/www/demo

    ${pkgs.certbot}/bin/certbot certonly \
      --manual \
      --preferred-challenges dns \
      --manual-auth-hook "${timeweb-auth-script}/bin/timeweb-auth-script" \
      --agree-tos \
      -d '*.${sensitive.sentinel.main-domain.domain}' \
      --preferred-chain "ISRG Root X1"

    sleep 10

    chown -R nginx:acme /etc/letsencrypt/ # nginx..
    chmod 755 /etc/letsencrypt/ # nginx...
  '';
in
{
  sops.secrets."guide/dns/dns-api-token" = {
    sopsFile = sensitive.guide.secrets;
    mode = "0444";
    key = "dns/dns-api-token";
  };

  # certbot renew -- based on https://github.com/qsdrqs/mydotfiles/blob/5282bd45cd80fafc81d7ec647d821253b25681e8/nixos/server-configuration.nix#L32
  systemd.services.certbot-renew = {
    enable = true;
    description = "Certbot Renewal";
    path = [ pkgs.curl ];
    serviceConfig = {
      ExecStart = "${certbot-script}/bin/certbot-script";
      Restart = "on-failure";
      RestartSec = 5;
    };
    after = [
      "sops-nix.service"
      "network.target"
    ];
    wantedBy = [
      "sops-nix.service"
      "multi-user.target"
    ];
  };
  systemd.timers.certbot-renew = {
    enable = config.systemd.services.certbot-renew.enable;
    description = "Weekly renewal of Let's Encrypt's certificates by certbot";
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };
}
