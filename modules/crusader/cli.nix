self@{ config, pkgs, boot, agenix, godot, ultim-mc, sandwine, stable, ... }:
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

    # Nix stuff
    nix-index
    nh
    agenix.default
    docker-compose

    # For nvim-(mason?). Think about getting read of these dependenices
    gnumake
    cargo
    rustc
    gcc

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

  programs.neovim.enable = true;
  programs.neovim.package = pkgs.neovim-unwrapped;

  # For gammastep
  services.geoclue2.enable = true;

  # TODO: fix
  #  services.zerotierone = {
  #    package = stable.zerotierone;
  #    enable = true;
  #    port = 25566;
  #  };
}
