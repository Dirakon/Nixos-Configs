{ pkgs
, sensitive
, ...
}:
let
  languageIdentifierModel = pkgs.fetchurl {
    url = "https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin";
    hash = "sha256-fmnsVFG8JhzHhE5J5HkqhdfwnAZ4nsgA/EpErsNidk4=";
  };
in
let
  port = sensitive.sentinel.languagetool.port;
in
{
  services.languagetool = {
    enable = true;
    allowOrigin = "*";
    public = true;
    port = port;
    settings = {
      fasttextModel = "${languageIdentifierModel}";
      fasttextBinary = "${pkgs.fasttext}/bin/fasttext";
    };
  };

  networking.firewall.allowedTCPPorts =
    [
      port
    ];
  networking.firewall.allowedUDPPorts =
    [
      port
    ];
}
