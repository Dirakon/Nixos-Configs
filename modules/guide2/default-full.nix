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
    sysz # cool systemd explorer

    # Nix stuff
    nh
  ];

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  services.openssh.ports = [ sensitive.guide2.ssh.port ];


  networking.hostName = "${hostname}";
}
