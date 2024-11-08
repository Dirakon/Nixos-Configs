self@{ config
, pkgs
, boot
, amneziawg-tools
, amneziawg-go
, sensitive
, nvimPackages
, ...
}:
# TODO: need to somehow
# env -u TMUX -- kitty fish --login --init-command "dev ^^FILE^^"
# but with alacritty??
# let
#   alacrittyConfig = builtins.toFile ".alacritty-nvim-config" ''
#     import = ["/home/dirakon/.config/alacritty/alacritty.toml"]
#
#     [shell]
#     program = "${pkgs.fish}/bin/fish"
#     args = ["--login", "--no-config", "--init-command", "exec ${nvimPackages.dev}/bin/dev $FILE_TO_OPEN"]
#   '';
# in
let
  alacrittyConfig = builtins.toFile ".alacritty-nvim-config" ''
    import = ["/home/dirakon/.config/alacritty/alacritty.toml"]

    [shell]
    program = "fish"
    args = ["--login", "--no-config", "--init-command", "exec dev $FILE_TO_OPEN"]
  '';
in
let
  customWrapper =
    (pkgs.makeDesktopItem {
      name = "nvim";
      desktopName = "Nvim";

      exec = "sh -c \"FILE_TO_OPEN=\\\\\"%f\\\\\" ${pkgs.alacritty}/bin/alacritty --config-file ${alacrittyConfig}\"";
      terminal = false;
      mimeTypes =
        [
          "text/english"
          "text/plain"
          "text/x-makefile"
          "text/x-c++hdr"
          "text/x-c++src"
          "text/x-chdr"
          "text/x-csrc"
          "text/x-java"
          "text/x-moc"
          "text/x-pascal"
          "text/x-tcl"
          "text/x-tex"
          "application/x-shellscript"
          "text/x-c"
          "text/x-c++"
        ];
    });
in
{
  environment.systemPackages =
    [
      customWrapper
    ]
    ++ (pkgs.lib.attrsets.attrValues nvimPackages);

  environment.variables.EDITOR = "dev";

  #     xdg.desktopEntries.org-protocol = {
  #   name = "org-protocol";
  #   exec = "emacsclient -- %u";
  #   terminal = false;
  #   type = "Application";
  #   categories = ["System"];
  #   mimeType = ["x-scheme-handler/org-protocol"];
  # };

}
