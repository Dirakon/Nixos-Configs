self@{ config, pkgs, unstable, nix-alien, nix-gl, ... }:
{
  nixpkgs.overlays = [ nix-gl.overlay ];

  environment.systemPackages = with pkgs; [
    nix-index
    nix-alien.nix-alien
    # pkgs.nixgl.nixGLIntel # If encounter some openGL problem look into this
    # pkgs.nixgl.auto.nixGLDefault # broken for some reason
  ];

  programs.nix-ld.enable = true;
  # Sets up all the libraries to load
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    openssl
    xorg.libXcomposite
    xorg.libXtst
    xorg.libXrandr
    xorg.libXext
    xorg.libX11
    xorg.libXfixes
    libGL
    libva
    # pipewire.lib # Works on https://unix.stackexchange.com/questions/522822/different-methods-to-run-a-non-nixos-executable-on-nixos tho?
    xorg.libxcb
    xorg.libXdamage
    xorg.libxshmfence
    xorg.libXxf86vm
    libelf

    # Required
    glib
    gtk2
    bzip2

    # Without these it silently fails
    xorg.libXinerama
    xorg.libXcursor
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXi
    xorg.libSM
    xorg.libICE
    gnome2.GConf
    nspr
    nss
    cups
    libcap
    SDL2
    libusb1
    dbus-glib
    ffmpeg
    # Only libraries are needed from those two
    libudev0-shim

    # Verified games requirements
    xorg.libXt
    xorg.libXmu
    libogg
    libvorbis
    SDL
    SDL2_image
    glew110
    libidn
    tbb

    # Other things from runtime
    flac
    freeglut
    libjpeg
    libpng
    libpng12
    libsamplerate
    libmikmod
    libtheora
    libtiff
    pixman
    speex
    SDL_image
    SDL_ttf
    SDL_mixer
    SDL2_ttf
    SDL2_mixer
    libappindicator-gtk2
    libdbusmenu-gtk2
    libindicator-gtk2
    libcaca
    libcanberra
    libgcrypt
    libvpx
    librsvg
    xorg.libXft
    libvdpau
    gnome2.pango
    cairo
    atk
    gdk-pixbuf
    fontconfig
    freetype
    dbus
    alsaLib
    expat
    # Needed for electron
    libdrm
    mesa
    libxkbcommon
  ];
}
