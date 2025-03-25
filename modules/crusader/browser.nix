self@{ config
, pkgs
, ...
}:
let
  mimeTypes =
    [
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
{
  environment.systemPackages = with pkgs; [
    chromium
    brave
    floorp
  ];

  # set default browser for Electron apps
  environment.sessionVariables.DEFAULT_BROWSER = "${pkgs.floorp}/bin/floorp";

  # For local usage (currently I'm hosting it on sentinel instead - see languagetool.nix):
  # services.languagetool = {
  #   enable = true;
  #   allowOrigin = "*";
  #   settings = {
  #     fasttextModel = "${languageIdentifierModel}";
  #     fasttextBinary = "${pkgs.fasttext}/bin/fasttext";
  #   };
  # };

  # TODO: migrate to home-manager managed one, with extensions
  programs.firefox.preferences =
    {
      package = pkgs.floorp;
      settings =
        {
          "browser.urlbar.placeholderName" = "DuckDuckGo";
          # TODO: more settings (but will require declarative tree-style-tabs...)
        };
    };

  home-manager.users.dirakon.xdg.mimeApps.defaultApplications =
    pkgs.lib.mergeAttrsList
      (builtins.map (mimeType: { "${mimeType}" = "floorp.desktop"; }) mimeTypes);
}
