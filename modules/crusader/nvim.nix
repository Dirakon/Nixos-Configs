self@{ config
, pkgs
, boot
, amneziawg-tools
, amneziawg-go
, sensitive
, nvimPackages
, ...
}:
# kitty is much easier to do (wtf alacritty)
# env -u TMUX -- kitty fish --login --init-command "dev ^^FILE^^"
# (this would even open with tmux, pretty cool)
# (and wouldn't need double escape)
let
  alacrittyConfig = pkgs.writeText ".alacritty-nvim-config" ''
    import = ["/home/dirakon/.config/alacritty/alacritty.toml"]

    [shell]
    program = "${pkgs.fish}/bin/fish"
    args = ["--login", "--no-config", "--init-command", "exec ${nvimPackages.dev}/bin/dev $FILE_TO_OPEN"]
  '';
in
let
  customNvimWrapper =
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
      customNvimWrapper
    ]
    ++ (pkgs.lib.attrsets.attrValues nvimPackages);

  environment.variables.EDITOR = "dev";
}
