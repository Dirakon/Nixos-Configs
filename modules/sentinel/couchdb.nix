self@{ lib, config, pkgs, boot, hostname, sensitive, ... }:
# go to hell couchdb WHY DO YOU NEED TO TOUCH MY CONFIGS
# THEY ARE NOT FOR YOUR FILTHY LITTLE HANDS!!
let
  couchdb-config-copier =
    pkgs.writeShellScriptBin "couchdb-config-copier" ''
      mkdir -p /var/shared_files/couchdbsaver/
      rm /var/shared_files/couchdbsaver/couchdb.conf
      cp "${config.sops.templates."couchdb.conf".path}" /var/shared_files/couchdbsaver/couchdb.conf
      chmod 777 /var/shared_files/couchdbsaver/couchdb.conf
    '';
in
{
  systemd.tmpfiles.rules = [
    "d /var/shared_files 1777 root root"
  ];
  services.couchdb = {
    enable = true;
    bindAddress = "0.0.0.0";
    port = sensitive.sentinel.obsidian-couchdb.port;
    configFile = "/var/shared_files/couchdbsaver/couchdb.conf";
  };

  sops.secrets."couchdb/password" = {
    sopsFile = sensitive.sentinel.secrets;
    mode = "0444";
    key = "couchdb/password";
  };

  sops.secrets."couchdb/login" = {
    sopsFile = sensitive.sentinel.secrets;
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

  systemd.services.couchdb-config-copier = {
    enable = true;
    description = "couchdb-config-copier";
    serviceConfig = {
      ExecStart = "${couchdb-config-copier}/bin/couchdb-config-copier";
      Restart = "on-failure";
      RestartSec = 5;
    };
    after = [ "sops-nix.service" "network.target" ];
    wantedBy = [ "sops-nix.service" "multi-user.target" ];
  };

  systemd.services.couchdb.serviceConfig.Restart = lib.mkForce "always";
  systemd.services.couchdb.serviceConfig.RestartSec = lib.mkForce 5;
  systemd.services.couchdb.after = [ "couchdb-config-copier.service" ];
  systemd.services.couchdb.wantedBy = [ "couchdb-config-copier.service" ];
}
