self@{ config, pkgs, boot, hostname, ... }:
{
  services.couchdb = {
    enable = true;
    bindAddress = "0.0.0.0";
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

  # https://github.com/vrtmrz/obsidian-livesync/blob/main/docs/setup_own_server.md#configure
  # and https://github.com/caffineehacker/nix/blob/376ef61905b65d250f01e76620d6c4847e3882b1/containers/obsidian-livesync.nix#L22
  sops.templates."couchdb.conf" = {
    mode = "0777"; # why does it need write access to config file.....
    content = ''
      [admins]
      ${config.sops.placeholder."couchdb/login"} = ${config.sops.placeholder."couchdb/password"}

      [couchdb]
      single_node = true
      max_document_size = 50000000

      [chttpd]
      require_valid_user = true
      max_http_request_size = 4294967296
      enable_cors = true

      [chttpd_auth]
      require_valid_user = true
      authentication_redirect = /_utils/session.html

      [httpd]
      WWW-Authenticate = Basic realm="couchdb"
      enable_cors = true

      [cors]
      credentials = true
      origins = app://obsidian.md,capacitor://localhost,http://localhost
    '';
  };

}
