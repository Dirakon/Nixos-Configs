self@{ config
, pkgs
, boot
, nixCats
, amneziawg-tools
, amneziawg-go
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

    # Nix stuff
    nix-index
    nh
    docker-compose
    sops

    nixCats.dev
    nixCats.idev
    # nixCats.hidev # <- TOOD: add this with i3-swallow (is there aerospace swallow?)

    # For playing audio
    sox # 'play' command

    # Performance
    s-tui
    stress

    # amneziawg
    amneziawg-go
    amneziawg-tools
  ];

  virtualisation.docker.enable = true;

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
  environment.variables.EDITOR = "idev";

  # For gammastep
  services.geoclue2.enable = true;

  # TODO: fix
  #  services.zerotierone = {
  #    package = stable.zerotierone;
  #    enable = true;
  #    port = 25566;
  #  };
}
