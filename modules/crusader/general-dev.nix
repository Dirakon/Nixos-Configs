self@{ config
, pkgs
, godot
, sensitive
, unstable
, ...
}:
let
  with-or = pkgs.writeShellScriptBin "with-or" ''
    export OPENROUTER_API_KEY="$(cat '/run/secrets/crusader/openrouter-key')"
    exec "$@"
  '';
in
let
  with-or2 = pkgs.writeShellScriptBin "with-or2" ''
    export OPENROUTER_API_KEY="$(cat '/run/secrets/crusader/openrouter-key2')"
    exec "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    vim
    hoppscotch
    lazysql
    unstable.aider-chat-with-playwright
    unstable.opencode
    with-or
    with-or2
    hawkeye # license headers and stuff

    # Nix stuff
    nix-index
    nh
    docker-compose
    distrobox
    sops
  ];

  sops.secrets."crusader/openrouter-key" = {
    sopsFile = sensitive.crusader.secrets;
    mode = "0444";
    key = "openrouter_key";
  };

  sops.secrets."crusader/openrouter-key2" = {
    sopsFile = sensitive.crusader.secrets;
    mode = "0444";
    key = "openrouter_key2";
  };

  programs.java.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Easy shell environments
  home-manager.users.dirakon.programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    silent = true;
    nix-direnv.enable = true;
  };
}
