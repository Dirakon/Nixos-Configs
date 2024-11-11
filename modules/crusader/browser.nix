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
  ];

  # set default browser for Electron apps
  environment.sessionVariables.DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";

  # TODO: migrate to home-manager managed one, with extensions
  programs.firefox.enable = true;
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
}
