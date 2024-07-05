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

    xray
  ];

  virtualisation.docker.enable = true;

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 2 * 1024; # 2 gigs
  }];


  services.openssh.ports = [ 55932 ];

  networking.firewall.allowedTCPPorts =
    [
      55932
      80
      443
      22
    ];
  networking.firewall.allowedUDPPorts =
    [
      55932
      80
      443
      22
    ];




  services.xray.enable = true;
  services.xray.package = pkgs.xray;
  # TODO: encrypted settings file
  services.xray.settingsFile = "/xray.json";



  networking.hostName = "${hostname}";
}
