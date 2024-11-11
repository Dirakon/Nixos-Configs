self@{ config
, pkgs
, ...
}:
# TODO: move to to sentinel.
# However, need to somehow protect it. Maybe by IP on nginx???
let
  languageIdentifierModel = pkgs.fetchurl {
    url = "https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin";
    hash = "sha256-fmnsVFG8JhzHhE5J5HkqhdfwnAZ4nsgA/EpErsNidk4=";
  };
in
{
  environment.systemPackages = with pkgs; [
    chromium
    brave
  ];

  # set default browser for Electron apps
  environment.sessionVariables.DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";

  # TODO: migrate to home-manager managed one, with extensions
  programs.firefox.enable = true;
  # use if (for some reason) firefox ain't compiled
  #programs.firefox.package = pkgs.firefox-bin;

  services.languagetool = {
    enable = true;
    settings = {
      fasttextModel = "${languageIdentifierModel}";
      fasttextBinary = "${pkgs.fasttext}/bin/fasttext";
    };
  };
}
