self@{ config, pkgs, boot, hostname, ... }:
{
  # New cache? Doesn't make difference
  #  nix.binaryCaches = [ "https://aseipp-nix-cache.global.ssl.fastly.net" ];
  nix.package = pkgs.lix;

  services.thermald.enable = true;
  services.tlp.enable = true;
  # use 'performance' on AC if needed
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    # CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
  };
  services.undervolt = {
    enable = true;
    temp = 60;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "${hostname}";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  # boot.kernel.sysctl."net.ipv6.conf.eth0.disable_ipv6" = true; # Example
  boot.kernel.sysctl."net.ipv6.conf.enp7s0.disable_ipv6" = true;
  #boot.kernel.sysctl."net.ipv6.conf.wg0.disable_ipv6" = true; # wireguard sadface
  boot.kernel.sysctl."net.ipv6.conf.wlp8s0.disable_ipv6" = true;
  networking.enableIPv6 = false;




  # networking.wg-quick.interfaces = {
  #     wg0 = {
  #       configFile = "/.secrets/wg0.conf";
  #      };
  #   };

  # Setup from https://nixos.wiki/wiki/WireGuard to allow wireguard
  networking.firewall.checkReversePath = false;
  networking.firewall = {
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
    allowedTCPPorts = [
      25565 # Minecraft
      25566 # Zerotier
      53
      51871 # wg???
    ];
    allowedUDPPorts = [
      25566 # Zerotier
      53
      51871 # wg???
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
    #  if packets are still dropped, they will show up in dmesg
    logReversePathDrops = true;
    #  wireguard trips rpfilter up
    # extraCommands = ''
    #   ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 57798 -j RETURN
    #   ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 57798 -j RETURN
    # '';
    # extraStopCommands = ''
    #   ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 57798 -j RETURN || true
    #   ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 57798 -j RETURN || true
    # '';
  };


  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.udisks2.enable = true;
  services.upower.enable = true;

  security.polkit.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  zramSwap.enable = true;

  fonts.packages = with pkgs; [
    (nerdfonts) #.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  systemd.extraConfig = "DefaultLimitNOFILE=65535"; # defaults to 1024 if unset

  system.stateVersion = "23.11"; # Install value! Don't change
}
