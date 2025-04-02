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
    ffmpeg-full # media backend and utils
    gifski # gif helper for ffmpeg - https://stackoverflow.com/a/47486545

    # For playing audio
    sox # 'play' command

    # Performance
    s-tui
    stress

    # amneziawg
    amneziawg-go
    amneziawg-tools
  ];

  programs.fish.enable = true;
  # To overwrite fish command-not-found, which breaks, so we create our own (./.config/fish/config.fish)
  programs.command-not-found.enable = false;
  users.defaultUserShell = pkgs.fish;

  home-manager.users.dirakon =
    {
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

  # TODO: fix
  #  services.zerotierone = {
  #    package = stable.zerotierone;
  #    enable = true;
  #    port = 25566;
  #  };

  programs.yazi.enable = true;
}
