# Based on https://github.com/wpdevelopment11/xray-tutorial
{ pkgs, config, lib, sensitive, ... }:
let
  recursiveMerge = attrList:
    let
      f = attrPath:
        builtins.zipAttrsWith (n: values:
          if builtins.tail values == [ ]
          then builtins.head values
          else if builtins.all builtins.isList values
          then builtins.unique (builtins.concatLists values)
          else if builtins.all builtins.isAttrs values
          then f (attrPath ++ [ n ]) values
          else builtins.last values
        );
    in
    f [ ] attrList;
in
let xrayValues = [ "hiding_domain" "hiding_ip" "uuid" "public_key" ]; in
let
  xrayConfigPart = recursiveMerge (builtins.map
    (value:
      {
        sops.secrets."xray/${value}" = {
          mode = "0444";
        };
      }
    )
    xrayValues);
in
let
  baseConfigPart =
    {
      environment.systemPackages = [
        pkgs.tsocks
      ];

      environment.etc."tsocks.conf".text = ''
        server = 127.0.0.1
        server_port = 10808
      '';

      services.xray.enable = true;
      services.xray.settingsFile = "${config.sops.templates."xray.json".path}";

      # systemd restart (otherwise weird failures are possible for some reason):
      systemd.services.xray.serviceConfig.Restart = lib.mkForce "always";
      systemd.services.xray.serviceConfig.RestartSec = lib.mkForce 5;

      sops.templates."xray.json" = {
        mode = "0444";
        content = ''
            {
              "log": {
                  "loglevel": "debug"
              },
              "inbounds": [
                  {
                      "listen": "127.0.0.1", 
                      "port": 10808, 
                      "protocol": "socks",
                      "settings": {
                          "udp": true
                      },
                      "sniffing": {
                          "enabled": true,
                          "destOverride": [
                              "http",
                              "tls",
                              "quic"
                          ],
                          "routeOnly": true
                      }
                  }
              ],
              "outbounds": [
                  {
                      "protocol": "vless",
                      "settings": {
                          "vnext": [
                              {
                                  "address": "${sensitive.guide.ip}", 
                                  "port": 443, 
                                  "users": [
                                      {
                                          "id": "${config.sops.placeholder."xray/uuid"}", // Needs to match server side
                                          "encryption": "none",
                                          "flow": "xtls-rprx-vision"
                                      }
                                  ]
                              }
                          ]
                      },
                      "streamSettings": {
                          "network": "tcp",
                          "security": "reality",
                          "realitySettings": {
                              "fingerprint": "chrome", 
                              "serverName": "${config.sops.placeholder."xray/hiding_domain"}", // A website that support TLS1.3 and h2. If your dest is `1.1.1.1:443`, then leave it empty
                              "publicKey": "${config.sops.placeholder."xray/public_key"}", // run `xray x25519` to generate. Public and private keys need to be corresponding.
                              "spiderX": "/dns-query/", // If your dest is `1.1.1.1:443`, then you can fill it with `/dns-query/` or just leave it empty
                              "shortId": "" // Required
                          }
                      },
                      "tag": "proxy"
                  }
              ]
          }
        '';
      };
    };
in
recursiveMerge [ xrayConfigPart baseConfigPart ]
