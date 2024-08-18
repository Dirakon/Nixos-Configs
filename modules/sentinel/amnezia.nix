self@{ config, pkgs, boot, stable, hostname, modulesPath, amneziawg-go, amneziawg-tools, lib, ... }:
let
  wg-start-and-wait-subprocesses = pkgs.writeShellScriptBin "wg-start-and-wait-subprocesses" ''
    ${amneziawg-tools}/bin/awg-quick up wg0
    pids=$(${pkgs.procps}/bin/pgrep amneziawg)
    # Why cant you wait for non-children...
    # wait $pids
    while [ -e /proc/$pids ]; do sleep 3; done
  '';
in
let
  wg-auto-server-pinger = pkgs.writeShellScriptBin "wg-auto-server-pinger" ''
    # Cuz without ping the connection sometimes is not established?
    while [ true ]; do 
      ${pkgs.iputils}/bin/ping -W 3 -c 3 10.0.0.1
      sleep 60
    done
  '';
in
{
  sops.secrets."sentinel/awg/private-key" = {
    sopsFile = ./../../secrets/sentinel-private.yaml;
    mode = "0444";
    key = "awg/private-key";
  };
  sops.secrets."guide2/awg/public-key" = {
    sopsFile = ./../../secrets/guide2-public.yaml;
    mode = "0444";
    key = "awg/public-key";
  };
  sops.secrets."guide2/ip" = {
    sopsFile = ./../../secrets/guide2-public.yaml;
    mode = "0444";
    key = "ip";
  };

  sops.templates."wg0.conf" = {
    mode = "0444";
    content = ''
      [Interface]
      Address = 10.0.0.2/24
      PrivateKey = ${config.sops.placeholder."sentinel/awg/private-key"}

      [Peer]
      PublicKey = ${config.sops.placeholder."guide2/awg/public-key"}
      AllowedIPs = 10.0.0.1/32
      Endpoint = ${config.sops.placeholder."guide2/ip"}:51871
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

  systemd.services."amnezia-auto-pinger" = {
    after = [ "awg-auto.service" ];
    wantedBy = [ "awg-auto.service" ];
    enable = true;
    serviceConfig =
      {
        Restart = "on-failure";
        ExecStart = "${wg-auto-server-pinger}/bin/wg-auto-server-pinger";
        RestartSec = 5;
      };
  };
  # Wants=sshd-keygen.service
  # After=network.target sshd-keygen.service
}
