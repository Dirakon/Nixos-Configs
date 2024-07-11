self@{ config, nix, pkgs, boot, stable, hostname, networking, ... }:
{
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "admin+acme@example.com";
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    virtualHosts = {
      "matchmakingServer.crabdance.com" = {
        forceSSL = true;
        enableACME = true;
        # All serverAliases will be added as extra domain names on the certificate.
        serverAliases = [ ];
        locations."/" = {
          proxyPass = "http://127.0.0.1:12345";
          proxyWebsockets = true; # needed if you need to use WebSocket
        };
      };
    };
  };

  # TODO: separate file
  services.couchdb = {
    enable = true;
    package = pkgs.couchdb3;
    # TODO: admin credentials somehow...
  };
}
