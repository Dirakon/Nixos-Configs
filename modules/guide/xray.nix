{ pkgs, config, lib, sensitive, my-utils, ... }:
let xrayValues = [ "hiding_domain" "hiding_ip" "uuid" "public_key" "private_key" ]; in
let
  xrayConfigPart = my-utils.recursiveMerge (builtins.map
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
      # TODO: nginx to proxy towards "hiding_ip", among other things
      # TODO: different keys for sops - one for crusader, one for guide
      # TODO: also similary assemble throne client config

      services.xray.enable = true;
      services.xray.settingsFile = "${config.sops.templates."xray.json".path}";

      # systemd restart (otherwise weird failures are possible for some reason):
      systemd.services.xray.serviceConfig.Restart = lib.mkForce "always";
      systemd.services.xray.serviceConfig.RestartSec = lib.mkForce 5;

      sops.templates."xray-connection-string" = {
        mode = "0444";
        content = ''vless://${config.sops.placeholder."xray/uuid"}@${sensitive.guide.ip}:443/?encryption=none&type=tcp&sni=${config.sops.placeholder."xray/hiding_domain"}&fp=chrome&security=reality&alpn=h2&flow=xtls-rprx-vision&pbk=${config.sops.placeholder."xray/public_key"}&packetEncoding=xudp'';
      };
      sops.templates."xray.json" = {
        mode = "0444";
        content = ''
          {
            "log": {
              "loglevel": "info"
            },
            "inbounds": [
              {
                "listen": "${sensitive.guide.ip}",
                "port": 444,
                "protocol": "vless",
                "tag": "reality-in",
                "settings": {
                  "clients": [
                    {
                      "id": "${config.sops.placeholder."xray/uuid"}",
                      "email": "user1",
                      "flow": "xtls-rprx-vision"
                    }
                  ],
                  "decryption": "none"
                },
                "streamSettings": {
                  "network": "tcp",
                  "security": "reality",
                  "realitySettings": {
                    "show": false,
                    "dest": "${config.sops.placeholder."xray/hiding_domain"}:443",
                    "xver": 0,
                    "serverNames": [
                      "${config.sops.placeholder."xray/hiding_domain"}"
                    ],
                    "privateKey": "${config.sops.placeholder."xray/private_key"}",
                    "minClientVer": "",
                    "maxClientVer": "",
                    "maxTimeDiff": 0,
                    "shortIds": [""]
                  }
                },
                "sniffing": {
                  "enabled": true,
                  "routeOnly": true,
                  "destOverride": [
                    "http",
                    "tls",
                    "quic"
                  ]
                }
              }
            ],
            "outbounds": [
              {
                "protocol": "freedom",
                "tag": "direct"
              },
              {
                "protocol": "blackhole",
                "tag": "block"
              }
            ],
            "routing": {
              "rules": [
              ],
              "domainStrategy": "IPIfNonMatch"
            }
          }
        '';
      };
    };
in
my-utils.recursiveMerge [ xrayConfigPart baseConfigPart ]

