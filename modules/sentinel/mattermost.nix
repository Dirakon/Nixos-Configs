self@{ config, pkgs, boot, hostname, sensitive, mattermost-printer-bot, ... }:
let
  run-mattermost-printer-bot = pkgs.writeShellScriptBin "run-mattermost-printer-bot" ''
    token=`cat ${config.sops.secrets."sentinel/mattermost/printer-bot-token".path}`
    PATH=$PATH:${pkgs.cups}/bin/
    ${mattermost-printer-bot}/bin/mattermost-printer-bot "Home" "https://${sensitive.sentinel.chat.hostname}" "$token"
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
    listenAddress = "0.0.0.0:34231";
    siteUrl = "https://${sensitive.sentinel.chat.hostname}";
    preferNixConfig = true;
  };
}
