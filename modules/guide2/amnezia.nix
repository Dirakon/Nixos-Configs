self@{ config, pkgs, boot, hostname, modulesPath, amneziawg-go, amneziawg-tools, lib, sensitive, ... }:
let
  wg-start-and-wait-subprocesses = pkgs.writeShellScriptBin "wg-start-and-wait-subprocesses" ''
    ${amneziawg-tools}/bin/awg-quick up wg0
    pids=$(${pkgs.procps}/bin/pgrep amneziawg)
    # Why cant you wait for non-children...
    # wait $pids
    while [ -e /proc/$pids ]; do sleep 60; done
  '';
in
{
  sops.secrets."guide2/awg/private-key" = {
    sopsFile = sensitive.guide2.secrets;
    mode = "0444";
    key = "awg/private-key";
  };

  sops.templates."wg0.conf" = {
    mode = "0444";
    content = ''
      [Interface]
      Address = ${sensitive.guide2.awg.ip}/32
      ListenPort = ${toString sensitive.guide2.awg.port}
      PrivateKey = ${config.sops.placeholder."guide2/awg/private-key"}
      Jc = 5
      Jmin = 100
      Jmax = 1000
      S1 = 324
      S2 = 452
      H1 = 25

      [Peer]
      PublicKey = ${sensitive.sentinel.awg.public-key}
      AllowedIPs = ${sensitive.sentinel.awg.ip}/24
      PersistentKeepalive = 25
    '';
  };

  environment.etc."amnezia/amneziawg/wg0.conf".source = "${config.sops.templates."wg0.conf".path}";

  environment.systemPackages = with pkgs; [
    amneziawg-tools
    amneziawg-go
  ];

  systemd.services."awg-auto" = {
    enable = true;
    after = [ "sops-nix.service" "network.target" ];
    wantedBy = [ "sops-nix.service" "multi-user.target" ];
    description = "automatic awg-quick setupper";
    serviceConfig =
      {
        Type = "simple";
        Restart = "on-failure";
        ExecStart = "${wg-start-and-wait-subprocesses}/bin/wg-start-and-wait-subprocesses";
        RestartSec = 5;
      };
  };

}
