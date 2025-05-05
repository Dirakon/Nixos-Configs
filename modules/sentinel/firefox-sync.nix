{ config, pkgs, sensitive, ... }:
{
  sops.secrets."fsync/master-secret" = {
    sopsFile = sensitive.sentinel.secrets;
    mode = "0444";
    key = "fsync/master-secret";
  };

  sops.secrets."fsync/metrics-secret" = {
    sopsFile = sensitive.sentinel.secrets;
    mode = "0444";
    key = "fsync/metrics-secret";
  };

  sops.templates."fsync.conf" = {
    mode = "0777";
    content = ''
      SYNC_MASTER_SECRET=${config.sops.placeholder."fsync/master-secret"}
      SYNC_TOKENSERVER__FXA_METRICS_HASH_SECRET=${config.sops.placeholder."fsync/metrics-secret"}
    '';
  };

  services.mysql.package = pkgs.mariadb;
  services.mysql.enable = true;

  services.firefox-syncserver = {
    enable = true;
    # https://artemis.sh/2023/03/27/firefox-syncstorage-rs.html
    secrets = "${config.sops.templates."fsync.conf".path}";
    # logLevel = "info";
    logLevel = "trace";

    singleNode = {
      enable = true;
      url = "https://${sensitive.sentinel.firefox-syncserver.hostname}:${toString sensitive.sentinel.firefox-syncserver.port}";
      capacity = 20;
      hostname = "0.0.0.0";
    };

    settings.port = sensitive.sentinel.firefox-syncserver.port;
    settings.host = "0.0.0.0";
    # settings.syncstorage = {
    #   enabled = true;
    #   enable_quota = 0;
    #   limits.max_total_records = 1666; # See issues #298/#333
    # };
    # settings.tokenserver =
    #   {
    #     fxa_browserid_audience = "https://token.services.mozilla.com";
    #     fxa_browserid_issuer = "https://api.accounts.firefox.com";
    #     fxa_browserid_server_url = "https://verifier.accounts.firefox.com/v2";
    #   };
  };

  systemd.services.firefox-syncserver.serviceConfig.StateDirectory = "firefox-syncserver";

  networking.firewall.allowedTCPPorts = [ sensitive.sentinel.firefox-syncserver.port ];
}
