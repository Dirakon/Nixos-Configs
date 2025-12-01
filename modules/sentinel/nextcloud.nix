self@{ config, pkgs, boot, hostname, sensitive, lib, ... }:
{
  sops.secrets."nextcloud/password" = {
    # TODO: move secrets to sensitive repo (why not?)
    # Then would be like `sopsFile = sensitive.sentinel.secrets`
    # 'public' part would become just sensitive strings
    sopsFile = sensitive.sentinel.secrets;
    mode = "0444";
    key = "nextcloud/password";
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = sensitive.sentinel.nextcloud.hostname;
    config.adminpassFile = config.sops.secrets."nextcloud/password".path;
    https = true;
    configureRedis = true;
    settings = {
      maintenance_window_start = "4";
      proxy = "socks5://127.0.0.1:10808";
      trusted_proxies = [
        sensitive.guide2.awg.ip
      ];
      enabledPreviewProviders = [
        "OC\\Preview\\BMP"
        "OC\\Preview\\GIF"
        "OC\\Preview\\JPEG"
        "OC\\Preview\\Krita"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\MP3"
        "OC\\Preview\\OpenDocument"
        "OC\\Preview\\PNG"
        "OC\\Preview\\TXT"
        "OC\\Preview\\XBitmap"
        "OC\\Preview\\HEIC"
        "OC\\Preview\\Movie"
      ];
    };

    # (not enough apps available for current nextcloud imo - using imperative approach for now)
    # extraApps = {
    #   inherit (config.services.nextcloud.package.packages.apps) news contacts calendar tasks forms mail notes;
    # };
    # extraAppsEnable = true;

    # Auto-update Nextcloud Apps
    autoUpdateApps.enable = true;
    autoUpdateApps.startAt = "05:00:00";
    poolSettings = {
      pm = "dynamic";
      "pm.max_children" = "160";
      "pm.max_requests" = "700";
      "pm.max_spare_servers" = "120";
      "pm.min_spare_servers" = "40";
      "pm.start_servers" = "40";
    };

    phpOptions."opcache.interned_strings_buffer" = "64";

    config =
      {
        dbtype = "pgsql";
        dbuser = "nextcloud";
        dbhost = "/run/postgresql";
        dbname = "nextcloud";
      };
    database.createLocally = true;
  };

  environment.systemPackages = with pkgs; [
    exiftool
    ffmpeg
  ];

  # Database configuration
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
    # This authenticates the Unix user with the same name only, and that without the need for a password
    # ensureUsers = [
    #   {
    #     name = "nextcloud";
    #   }
    # ];

    # ensureDatabases = [
    #   "nextcloud"
    # ];
  };

  # Ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };

  networking.firewall.allowedTCPPorts =
    [
      80 # http
      443 # https
    ];
  networking.firewall.allowedUDPPorts =
    [
      80 # http
      443 # https
    ];
}
