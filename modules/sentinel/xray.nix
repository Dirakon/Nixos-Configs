# Based on https://github.com/XTLS/Xray-examples/blob/main/VLESS-TCP-XTLS-Vision-REALITY/config_client.jsonc
{ pkgs
, config
, lib
, sensitive
, my-utils
, ...
}:
let
  xrayValues = [
    "hiding_domain"
    "hiding_ip"
    "uuid"
    "public_key"
  ];
in
let
  xrayConfigPart = my-utils.recursiveMerge (
    builtins.map
      (value: {
        sops.secrets."xray/${value}" = {
          mode = "0444";
        };
      })
      xrayValues
  );
in
let
  gost-init =
    pkgs.writeShellScriptBin "gost-init" ''
      ${pkgs.gost}/bin/gost -L http://:20808 -F socks5://127.0.0.1:10808
    '';
in
let
  baseConfigPart = {
    environment.systemPackages = [
      pkgs.tsocks
      pkgs.gost
    ];

    systemd.services.gost-init = {
      enable = true;
      description = "Gost http proxy";
      serviceConfig = {
        ExecStart = "${gost-init}/bin/gost-init";
        Restart = "on-failure";
        RestartSec = 5;
      };
      after = [
        "sops-nix.service"
        "network.target"
      ];
      wantedBy = [
        "sops-nix.service"
        "multi-user.target"
      ];
    };

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
                                        "id": "${
                                          config.sops.placeholder."xray/uuid"
                                        }", // Needs to match server side
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
                            "serverName": "${
                              config.sops.placeholder."xray/hiding_domain"
                            }", // A website that support TLS1.3 and h2. If your dest is `1.1.1.1:443`, then leave it empty
                            "publicKey": "${
                              config.sops.placeholder."xray/public_key"
                            }", // run `xray x25519` to generate. Public and private keys need to be corresponding.
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
my-utils.recursiveMerge [
  xrayConfigPart
  baseConfigPart
]
