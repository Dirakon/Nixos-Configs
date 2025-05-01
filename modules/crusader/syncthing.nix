self@{ config, pkgs, boot, unstable, hostname, sensitive, ... }:
{
  users.users.dirakon.extraGroups = [ "syncthing" ];

  environment.systemPackages = with pkgs; [
    syncthing
  ];

  services = {
    syncthing = {
      enable = true;
      group = "syncthing";
      user = "dirakon";
      dataDir = "/home/dirakon/syncthing";
      configDir = "/home/dirakon/syncthing/.config/syncthing";
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      settings = {
        devices = {
          "sentinel" = { id = sensitive.sentinel.syncthing.device-id; };
          "droid" = { id = sensitive.droid.syncthing.device-id; };
        };
        folders = {
          "Notes" = {
            # Name of folder in Syncthing, also the folder ID
            path = "/home/dirakon/syncthing/Notes"; # Which folder to add to Syncthing
            devices = [ "sentinel" "droid" ]; # Which devices to share the folder with
          };
        };
      };
    };
  };


  networking.firewall.allowedTCPPorts =
    [
      22000
    ];
  networking.firewall.allowedUDPPorts =
    [
      22000
      21027
    ];
}
