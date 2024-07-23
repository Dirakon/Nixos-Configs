{ pkgs, config, lib, ... }:
# TODO: make my utils and propogate?
# https://stackoverflow.com/questions/54504685/nix-function-to-merge-attributes-records-recursively-and-concatenate-arrays
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
let xrayValues = [ "hiding_domain" "hiding_ip" "uuid" "public_key" "private_key" ]; in
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
      # TODO: nginx to proxy towards "hiding_ip", among other things
      # TODO: different keys for sops - one for crusader, one for guide
      # TODO: also similary assemble nekoray client config

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
              "loglevel": "info"
            },
            "inbounds": [
              {
                "listen": "${config.sops.placeholder."guide/ip"}",
                "port": 443,
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
                {
                  "type": "field",
                  "protocol": "bittorrent",
                  "outboundTag": "block"
                }
              ],
              "domainStrategy": "IPIfNonMatch"
            }
          }
        '';
      };

      # systemd.services."sometestservice" = {
      #   script = ''
      #       echo "
      #       Hey bro! I'm a service, and imma send this secure password:
      #       $(cat ${config.sops.secrets."myservice/my_subdir/my_secret".path})
      #       located in:
      #       ${config.sops.secrets."myservice/my_subdir/my_secret".path}
      #       to database and hack the mainframe
      #       " > /var/lib/sometestservice/testfile
      #     '';
      #   serviceConfig = {
      #     User = "sometestservice";
      #     WorkingDirectory = "/var/lib/sometestservice";
      #   };
      # };

      # users.users.sometestservice = {
      #   home = "/var/lib/sometestservice";
      #   createHome = true;
      #   isSystemUser = true;
      #   group = "sometestservice";
      # };
      # users.groups.sometestservice = { };

    };
in
recursiveMerge [ xrayConfigPart baseConfigPart ]

