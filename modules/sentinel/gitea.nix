self@{ config, pkgs, boot, hostname, sensitive, ... }:
{
  # based on https://github.com/ryan4yin/nix-config/blob/47e1ca61c3055d65e1b36bda7efcc570f5f2effa/hosts/idols-aquamarine/gitea.nix#L3
  services.gitea = {
    enable = true;
    user = "gitea";
    group = "gitea";
    stateDir = "/data/apps/gitea";
    appName = "My Gitea Service";
    lfs.enable = true;
    # Enable a timer that runs gitea dump to generate backup-files of the current gitea database and repositories.
    dump = {
      enable = false;
      interval = "hourly";
      file = "gitea-dump";
      type = "tar.zst";
    };
    # Path to a file containing the SMTP password.
    # mailerPasswordFile = "";
    settings = {
      server = {
        SSH_PORT = 51273;
        START_SSH_SERVER = true;
        SSH_DOMAIN = "${sensitive.sentinel.git.hostname}";
        # SSH_LISTEN_HOST = 51273;
        # SSH_LISTEN_PORT = 51273;
        SSH_ROOT_PATH = "~/.gitea-ssh";
        SSH_SERVER_USE_PROXY_PROTOCOL = false;
        PROTOCOL = "http";
        HTTP_PORT = 41239;
        HTTP_ADDR = "0.0.0.0";
        DOMAIN = "${sensitive.sentinel.git.hostname}";
        ROOT_URL = "https://${sensitive.sentinel.git.hostname}/";
      };
      # one of "Trace", "Debug", "Info", "Warn", "Error", "Critical"
      log.LEVEL = "Info";
      # Marks session cookies as "secure" as a hint for browsers to only send them via HTTPS.
      session.COOKIE_SECURE = true;
      # NOTE: The first registered user will be the administrator,
      # so this parameter should NOT be set before the first user registers!
      service.DISABLE_REGISTRATION = true;
      #service.SHOW_REGISTRATION_BUTTON = false;
      service.REQUIRE_SIGNIN_VIEW = true;
      # https://docs.gitea.com/administration/config-cheat-sheet#security-security
      security = {
        LOGIN_REMEMBER_DAYS = 31;
        PASSWORD_HASH_ALGO = "scrypt";
        MIN_PASSWORD_LENGTH = 10;
        REVERSE_PROXY_LIMIT = 2;
        REVERSE_PROXY_TRUSTED_PROXIES = "10.0.0.1"; # guide2 via amnezia-wg
      };
      "service.explore" = {
        REQUIRE_SIGNIN_VIEW = true;
      };

      # "cron.sync_external_users" = {
      #   RUN_AT_START = true;
      #   SCHEDULE = "@every 24h";
      #   UPDATE_EXISTING = true;
      # };
      # mailer = {
      #   ENABLED = true;
      #   MAILER_TYPE = "sendmail";
      #   FROM = "do-not-reply@writefor.fun";
      #   SENDMAIL_PATH = "${pkgs.system-sendmail}/bin/sendmail";
      # };
      # other = {
      #   SHOW_FOOTER_VERSION = false;
      # };
    };
    database = {
      type = "postgres";
      socket = "/run/postgresql";
      # create a local database automatically.
      createDatabase = true;
    };
  };
}
