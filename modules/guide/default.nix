self@{ config, nix, pkgs, boot, hostname, modulesPath, sensitive, ... }:
{
  users.users.dirakon = {
    isNormalUser = true;
    description = "dirakon";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" ];
    packages = [ ];
  };

  imports = [
    ./xray.nix
    ./amnezia.nix
    ./nginx.nix
    ./certbot.nix
    ./network.nix
    ./sops.nix
    (modulesPath + "/profiles/qemu-guest.nix")
    (sensitive.guide.networking-config)
  ];

  boot.loader.grub.device = "/dev/vda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = { device = "/dev/vda2"; fsType = "ext4"; };



  system.stateVersion = "23.11";


  boot.tmp.cleanOnBoot = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF03uj/UUSxx19vzMgnrfOwIflPP//GVHl2gIA4OYnlS dirakon@nixbox"
  ];
  users.users.dirakon.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF03uj/UUSxx19vzMgnrfOwIflPP//GVHl2gIA4OYnlS dirakon@nixbox"
  ];

  environment.systemPackages = with pkgs; [
    # some cli tools
    curl
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
    jq # json

    # Nix stuff
    nh
  ];

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

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


  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true; # enable copy and paste between host and guest


  services.openssh.ports = [ sensitive.guide.ssh.port ];

  nix.settings.trusted-users = [ "dirakon" ];

  # https://discourse.nixos.org/t/remote-nixos-rebuild-works-with-build-but-not-with-switch/34741/6
  # https://discourse.nixos.org/t/remote-nixos-rebuild-sudo-askpass-problem/28830/22
  security.sudo.wheelNeedsPassword = false;

  networking.hostName = "${hostname}";
}
