self@{ config
, pkgs
, boot
, amneziawg-tools
, amneziawg-go
, sensitive
, ...
}:
{
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
    btop
    fastfetch
    fuseiso
    imagemagick
    parted
    gparted
    tldr
    arp-scan
    poppler_utils # pdf to png thing - `pdftoppm`
    timer
    openssl
    cloc
    ncdu

    # Nix stuff
    nix-index
    nh
    docker-compose
    distrobox
    sops

    # For playing audio
    sox # 'play' command

    # Performance
    s-tui
    stress

    # amneziawg
    amneziawg-go
    amneziawg-tools
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  programs.fish.enable = true;
  # To overwrite fish command-not-found, which breaks, so we create our own (./.config/fish/config.fish)
  programs.command-not-found.enable = false;
  users.defaultUserShell = pkgs.fish;

  home-manager.users.dirakon =
    {
      # Easy shell environments
      programs.direnv = {
        enable = true;
        # enableNushellIntegration = true;
        # enableZshIntegration = true;
        enableFishIntegration = true;
        silent = true;
        nix-direnv.enable = true;
      };

      programs.fzf = {
        enable = true;
        enableFishIntegration = true;
      };

      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
      };

      home.file.".scripts/nix-command-not-found" = {
        text = ''
          #!/usr/bin/env bash
                source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
                command_not_found_handle "$@"
        '';

        executable = true;
      };
    };

  programs.java.enable = true;

  # TODO: fix
  #  services.zerotierone = {
  #    package = stable.zerotierone;
  #    enable = true;
  #    port = 25566;
  #  };
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

  programs.yazi.enable = true;
}
