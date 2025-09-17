self@{ config
, pkgs
, boot
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
    general.import = ["/home/dirakon/.config/alacritty/alacritty.toml"]

    [terminal.shell]
    program = "${pkgs.fish}/bin/fish"
    args = ["--login", "--no-config", "--init-command", "exec ${nvimPackages.dev}/bin/dev $FILE_TO_OPEN"]
  '';
in
let
  nvim-runner = pkgs.writeShellScriptBin "nvim-runner" ''
    FILE_TO_OPEN="$1" ${pkgs.alacritty}/bin/alacritty --config-file ${alacrittyConfig}
  '';
in
let
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
      "application/x-wine-extension-ini"
      "application/xml"
      "text/markdown"
      "text/x-log"
    ];
in
let
  customNvimWrapper =
    (pkgs.makeDesktopItem {
      name = "nvim";
      desktopName = "Nvim";
      exec = "${nvim-runner}/bin/nvim-runner %f";
      terminal = false;
      mimeTypes = mimeTypes;
    });
in
{
  environment.systemPackages =
    [
      customNvimWrapper
    ]
    ++ (pkgs.lib.attrsets.attrValues nvimPackages);

  environment.variables.EDITOR = "dev";

  home-manager.users.dirakon =
    {
      xdg.mimeApps.defaultApplications =
        pkgs.lib.mergeAttrsList
          (builtins.map (mimeType: { "${mimeType}" = "nvim.desktop"; }) mimeTypes);
    };
}
