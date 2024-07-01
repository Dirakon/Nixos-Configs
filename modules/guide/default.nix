self@{ config, pkgs, boot, stable, hostname, modulesPath, ... }:
{
  users.users.dirakon = {
    isNormalUser = true;
    description = "dirakon";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" ];
    packages = with pkgs; [ ];
  };

  imports = [
    ./disk-config.nix
    ./default-full.nix # Comment for first install for better resource usage
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  system.stateVersion = "23.11";

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  services.openssh.enable = true;

  disko.devices.disk.disk1.device = "/dev/vda";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF03uj/UUSxx19vzMgnrfOwIflPP//GVHl2gIA4OYnlS dirakon@nixbox"
  ];


  environment.systemPackages = with pkgs; [
    # gitMinimal # Temporary
    curl
  ];

  networking.hostName = "${hostname}";
}
