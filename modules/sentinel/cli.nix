self@{ config
, pkgs
, boot
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
    htop # just to test that unstabling works properly
    btop
    fastfetch
    fuseiso
    imagemagick
    parted
    gparted
    tldr
    arp-scan
    ncdu
    sysz # cool systemd explorer
    jq # json

    # Nix stuff
    nix-index
    nh
    docker-compose
    sops

    # For nvim-(mason?). Think about getting read of these dependenices
    # gnumake
    # cargo
    # rustc
    # gcc

    # For playing audio
    sox # 'play' command

    # Performance
    s-tui
    stress
  ];

  virtualisation.docker.enable = true;

  programs.fish.enable = true;
  # To overwrite fish command-not-found, which breaks, so we create our own (./.config/fish/config.fish)
  programs.command-not-found.enable = false;
  users.defaultUserShell = pkgs.fish;

  # I don't remember why I need it
  programs.java.enable = true;

  environment.variables.EDITOR = "vim";

  # TODO: fix
  #  services.zerotierone = {
  #    package = stable.zerotierone;
  #    enable = true;
  #    port = 25566;
  #  };
}
