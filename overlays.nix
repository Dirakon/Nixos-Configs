# ./overlays/default.nix
inputs@{ ... }:
[
  # https://github.com/rumboon/dolphin-overlay/blob/main/default.nix
  (
    final: prev: {
      kdePackages = prev.kdePackages.overrideScope (kfinal: kprev: {
        dolphin = kprev.dolphin.overrideAttrs (oldAttrs: {
          nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ prev.makeWrapper ];
          postInstall = (oldAttrs.postInstall or "") + ''
            wrapProgram $out/bin/dolphin \
                --set XDG_CONFIG_DIRS "${prev.libsForQt5.kservice}/etc/xdg:$XDG_CONFIG_DIRS" \
                --run "${kprev.kservice}/bin/kbuildsycoca6 --noincremental ${prev.libsForQt5.kservice}/etc/xdg/menus/applications.menu"
          '';
        });
      });
    }

  )
]
