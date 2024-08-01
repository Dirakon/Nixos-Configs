{ lib, ... }:
{
  # based on like https://github.com/kjhoerr/dotfiles/blob/bfab52ab659c86bb180eb5370ea264a5c0220e54/.config/nixos/home/helix.nix#L120
  # or better yet - https://github.com/Anomalocaridid/dotfiles/tree/1581f969188422fc60e39a2b2aa854fcfc9b1008/home/development
  # helix

  programs.helix = {
    enable = true;
    settings = {
      theme = "term16_dark";
      editor = {
        mouse = false;
        bufferline = "always";
        lsp.display-messages = true;
        indent-guides.render = true;
        cursorline = true;
        line-number = "relative";
        cursorcolumn = false;
        cursor-shape = {
          insert = "bar";
        };
        color-modes = true;
        statusline = {
          left = [
            "mode"
            "spinner"
            "file-name"
            "separator"
            "file-modification-indicator"
          ];
          right = [
            "diagnostics"
            "separator"
            "file-type"
            "separator"
            "selections"
            "separator"
            "position"
            "file-encoding"
          ];
          separator = "";
        };
      };

      keys = {
        normal = {
          # TODO: v-split for other apps instead? tmux? check https://github.com/luccahuguet/zellij
          # some problems would include helix not refreshing on external changes (need to do :refresh(-all))
          "C-g" = [
            # over current window
            ":new"
            ":insert-output lazygit"
            ":buffer-close!"
            ":redraw"
          ];
          tab = [ ":buffer-next" ];
          "S-tab" = [ ":buffer-previous" ];
          esc = [
            "collapse_selection"
            "keep_primary_selection"
          ];
          space = {
            x = [ ":buffer-close" ];
          };
        };
      };
    };
  };

  # programs.lazygit = {
  #   enable = true;
  # };

  imports = map (file: ./helix + "/${file}") (
    lib.strings.filter (file: file != "default.nix") (builtins.attrNames (builtins.readDir ./helix))
  );
}
