self@{ config, pkgs, boot, hostname, modulesPath, sensitive, ... }:
{
  imports = [
    ./nginx.nix
    ./network.nix
    ./sops.nix
    ./amnezia.nix
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
    fastfetch

    # Nix stuff
    nh

    # Docker stuff
    docker-compose
  ];

  virtualisation.docker.enable = true;

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  zramSwap = {
    enable = true;
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 2 * 1024; # 2 gigs
  }];


  services.openssh.ports = [ sensitive.guide2.ssh.port ];


  networking.hostName = "${hostname}";
}
