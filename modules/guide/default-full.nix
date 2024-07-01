self@{ config, pkgs, boot, stable, hostname, modulesPath, ... }:
{
  imports = [
  ];

  environment.systemPackages = with pkgs; [
    # some cli tools
    vim
    wget
    git
    lshw
    zip
    unzip
    ripgrep
    htop
    ncdu

    # Nix stuff
    nh

    # Docker stuff
    docker-compose
  ];

  virtualisation.docker.enable = true;

  # programs.fish.enable = true;
  # users.defaultUserShell = pkgs.fish;

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 2 * 1024; # 2 gigs
  }];

  networking.hostName = "${hostname}";
}
