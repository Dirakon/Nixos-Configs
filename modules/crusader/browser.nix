self@{ config
, pkgs
, ...
}:
let
  mimeTypes = [
    "application/x-extension-htm"
    "application/x-extension-html"
    "application/x-extension-shtml"
    "application/x-extension-xht"
    "application/x-extension-xhtml"
    "application/xhtml+xml"
    "text/html"
    "x-scheme-handler/chrome"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
  ];
in
# let
  #   languageIdentifierModel = pkgs.fetchurl {
  #     url = "https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin";
  #     hash = "sha256-fmnsVFG8JhzHhE5J5HkqhdfwnAZ4nsgA/EpErsNidk4=";
  #   };
  # in
let
  floorpPackage =
    with pkgs;
    floorp.override {
      nativeMessagingHosts = [
        tridactyl-native

      ];
    };
in
{
  environment.systemPackages = with pkgs; [
    chromium
    brave
    floorpPackage
    tridactyl-native # lessgo
  ];

  # set default browser for Electron apps
  environment.sessionVariables.DEFAULT_BROWSER = "${floorpPackage}/bin/floorp";

  # For local usage (currently I'm hosting it on sentinel instead - see languagetool.nix):
  # services.languagetool = {
  #   enable = true;
  #   allowOrigin = "*";
  #   settings = {
  #     fasttextModel = "${languageIdentifierModel}";
  #     fasttextBinary = "${pkgs.fasttext}/bin/fasttext";
  #   };
  # };

  home-manager.users.dirakon = {
    programs.floorp = {
      enable = true;
      package = floorpPackage;
      policies = {
        "ExtensionSettings" = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "normal_installed";
          };
          "treestyletab@piro.sakura.ne.jp" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tree-style-tab/latest.xpi";
            installation_mode = "normal_installed";
          };
          "sponsorBlocker@ajay.app" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
            installation_mode = "normal_installed";
          };
          "languagetool-webextension@languagetool.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/languagetool/latest.xpi";
            installation_mode = "normal_installed";
          };
          "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
            installation_mode = "normal_installed";
          };
          "{eb7bbaf9-d059-46ba-a8b3-73e0b31cae95}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/take-youtube-video-screenshots/latest.xpi";
            installation_mode = "normal_installed";
          };
          "tridactyl.vim@cmcaine.co.uk" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tridactyl-vim/latest.xpi";
            installation_mode = "normal_installed";
          };
        };
        SearchEngines.Default = "DuckDuckGo";
      };
    };
  };

  home-manager.users.dirakon.xdg.mimeApps.defaultApplications = pkgs.lib.mergeAttrsList (
    builtins.map (mimeType: { "${mimeType}" = "floorp.desktop"; }) mimeTypes
  );
}
