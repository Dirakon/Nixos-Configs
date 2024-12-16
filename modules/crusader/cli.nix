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

  # I don't remember why I need it
  programs.java.enable = true;

  # programs.neovim = {
  #   enable = true;
  #   defaultEditor = true;
  #   package = pkgs.neovim-unwrapped;
  # };

  # For gammastep
  services.geoclue2.enable = true;

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
}
