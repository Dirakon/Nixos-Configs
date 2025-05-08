self@{ config, pkgs, boot, hostname, sensitive, mattermost-printer-bot, ... }:
let
  run-mattermost-printer-bot = pkgs.writeShellScriptBin "run-mattermost-printer-bot" ''
    token=`cat ${config.sops.secrets."sentinel/mattermost/printer-bot-token".path}`

    ${mattermost-printer-bot}/bin/mattermost-printer-bot \
      "https://${sensitive.sentinel.mattermost.hostname}" \
      "Home" \
      "$token" \
      --print "${pkgs.cups}/bin/lp" \
      --scan "${pkgs.sane-backends}/bin/scanimage --jpeg=no --resolution=300 -o"
  '';
in
{
  sops.secrets."sentinel/mattermost/printer-bot-token" = {
    sopsFile = sensitive.sentinel.secrets;
    mode = "0444";
    key = "mattermost/printer-bot-token";
  };

  systemd.services."mattermost-printer-bot-auto" = {
    enable = true;
    after = [ "sops-nix.service" "network.target" ];
    wantedBy = [ "sops-nix.service" "multi-user.target" ];
    description = "automatic runner of mattermost-printer-bot";
    serviceConfig =
      {
        Type = "simple";
        Restart = "on-failure";
        ExecStart = "${run-mattermost-printer-bot}/bin/run-mattermost-printer-bot";
        RestartSec = 5;
      };
  };

  # based on https://github.com/arianvp/nixos-stuff/blob/78ad16e9653f4a7d97d83b732fa67e67a099f493/configs/arianvp.me/mattermost.nix#L3
  services.mattermost = {
    enable = true;
    listenAddress = "0.0.0.0:${toString sensitive.sentinel.mattermost.port}";
    siteUrl = "https://${sensitive.sentinel.mattermost.hostname}";
    preferNixConfig = true;
    extraConfig = {
      "SessionLengthMobileInDays" = 1000;
      "SessionLengthWebInDays" = 1000;
      "SessionLengthSSOInDays" = 1000;

      ServiceSettings = {
        "AllowedUntrustedInternalConnections" = "127.0.0.1 192.168.0.1/16";
      };
    };
  };

  networking.firewall.allowedTCPPorts =
    [
      sensitive.sentinel.mattermost.port
    ];
  networking.firewall.allowedUDPPorts =
    [
      sensitive.sentinel.mattermost.port
    ];
}
