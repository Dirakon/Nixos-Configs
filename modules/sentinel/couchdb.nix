self@{ config, pkgs, boot, hostname, ... }:
{
  services.couchdb = {
    enable = true;
    port = 54932;
    configFile = "${config.sops.templates."couchdb.conf".path}";
  };

  sops.secrets."couchdb/password" = {
    sopsFile = ./../../secrets/sentinel-private.yaml;
    mode = "0444";
    key = "couchdb/password";
  };

  sops.secrets."couchdb/login" = {
    sopsFile = ./../../secrets/sentinel-private.yaml;
    mode = "0444";
    key = "couchdb/login";
  };

  sops.templates."couchdb.conf" = {
    mode = "0444";
    content = ''
      [admins]
      ${config.sops.placeholder."couchdb/login"} = ${config.sops.placeholder."couchdb/password"}
    '';
  };

}
