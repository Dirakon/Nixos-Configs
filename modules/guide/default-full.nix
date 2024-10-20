self@{ config, pkgs, boot, hostname, modulesPath, sensitive, ... }:
{
  imports = [
    ./xray.nix
    ./network.nix
    ./sops.nix
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

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  zramSwap = {
    enable = true;
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 2 * 1024; # 2 gigs
  }];


  boot.kernel.sysctl = {
    # Xray stuff (TODO: in xray file?)
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
    "net.core.rmem_max" = 67108864;
    "net.core.wmem_max" = 67108864;
    "net.core.netdev_max_backlog" = 10000;
    "net.core.somaxconn" = 4096;
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_tw_reuse" = 1;
    "net.ipv4.tcp_fin_timeout" = 30;
    "net.ipv4.tcp_keepalive_time" = 1200;
    "net.ipv4.tcp_keepalive_probes" = 5;
    "net.ipv4.tcp_keepalive_intvl" = 30;
    "net.ipv4.tcp_max_syn_backlog" = 8192;
    "net.ipv4.tcp_max_tw_buckets" = 5000;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_mem" = "25600 51200 102400";
    "net.ipv4.udp_mem" = "25600 51200 102400";
    "net.ipv4.tcp_rmem" = "4096 87380 67108864";
    "net.ipv4.tcp_wmem" = "4096 65536 67108864";
    "net.ipv4.tcp_mtu_probing" = 1;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
  };


  services.openssh.ports = [ sensitive.guide.ssh.port ];


  networking.hostName = "${hostname}";
}
