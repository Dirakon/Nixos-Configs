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

        autoDownloadNewChapters = false;
        socksProxyEnabled = false;

        maxSourcesInParallel = 6;
        extensionRepos = [
          "https://raw.githubusercontent.com/ThePBone/tachiyomi-extensions-revived/repo/index.min.json"
          "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
        ];
        #     settings = {
        #       server.webUIEnabled = true;
        #       server.initialOpenInBrowserEnabled = false;
        #       server.systemTrayEnabled = false;
        #       server.socksProxyEnabled = false;
        #       server.webUIFlavor = "WebUI";
        #       server.webUIInterface = "browser";
        #       server.webUIChannel = "stable"; # "bundled" (the version bundled with the server release), "stable" or "preview" - the webUI version that should be used
        #       server.webUIUpdateCheckInterval = 23;
        #       server.globalUpdateInterval = 12;
        #       server.updateMangas = false;
        #     };
      };
    };
  };

  sops.secrets."suwayomi/password" = {
    sopsFile = sensitive.sentinel.secrets;
    mode = "0444";
    key = "suwayomi/password";
  };
}
