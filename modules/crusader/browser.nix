self@{ config
, pkgs
, ...
}:
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

  # TODO: migrate to home-manager managed one, with extensions
  # programs.firefox.enable = true;
  # use if (for some reason) firefox ain't compiled
  #programs.firefox.package = pkgs.firefox-bin;

  # For local usage (currently I'm hosting it on sentinel instead - see languagetool.nix):
  # services.languagetool = {
  #   enable = true;
  #   allowOrigin = "*";
  #   settings = {
  #     fasttextModel = "${languageIdentifierModel}";
  #     fasttextBinary = "${pkgs.fasttext}/bin/fasttext";
  #   };
  # };

  home-manager.users.dirakon =
    {
      xdg.mimeApps.defaultApplications =
        {
          "application/x-extension-htm" = "floorp.desktop";
          "application/x-extension-html" = "floorp.desktop";
          "application/x-extension-shtml" = "floorp.desktop";
          "application/x-extension-xht" = "floorp.desktop";
          "application/x-extension-xhtml" = "floorp.desktop";
          "application/xhtml+xml" = "floorp.desktop";
          "text/html" = "floorp.desktop";
          "x-scheme-handler/chrome" = "floorp.desktop";
          "x-scheme-handler/http" = "floorp.desktop";
          "x-scheme-handler/https" = "floorp.desktop";
        };
    };
}
