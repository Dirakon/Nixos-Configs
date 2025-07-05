self@{ config, pkgs, boot, unstable, hostname, sensitive, ... }:
{
  services.suwayomi-server = {
    package = unstable.suwayomi-server;
    enable = true;
    openFirewall = true;

    settings = {
      server = {
        ip = "0.0.0.0";
        port = sensitive.sentinel.suwayomi.port;
        basicAuthEnabled = true;
        basicAuthUsername = "dirakon";
        basicAuthPasswordFile = config.sops.secrets."suwayomi/password".path;

        systemTrayEnabled = false;
        webUIEnabled = true;
        initialOpenInBrowserEnabled = false;

        autoDownloadNewChapters = false;

        # See ./xray.nix
        socksProxyEnabled = true;
        socksProxyHost = "localhost";
        socksProxyPort = "10808";

        maxSourcesInParallel = 6;
        extensionRepos = [
          # "https://raw.githubusercontent.com/ThePBone/tachiyomi-extensions-revived/repo/index.min.json"
          "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
        ];
      };
    };
  };

  sops.secrets."suwayomi/password" = {
    sopsFile = sensitive.sentinel.secrets;
    mode = "0444";
    key = "suwayomi/password";
  };
}
