self@{ config, pkgs, boot, hostname, sensitive, ... }:
{
  # based on https://github.com/arianvp/nixos-stuff/blob/78ad16e9653f4a7d97d83b732fa67e67a099f493/configs/arianvp.me/mattermost.nix#L3
  services.mattermost = {
    enable = true;
    listenAddress = "0.0.0.0:34231";
    siteUrl = "https://${sensitive.sentinel.chat.hostname}";
    preferNixConfig = true;
  };
}
