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
{
  environment.systemPackages = with pkgs; [
    vim
    hoppscotch
    lazysql
    unstable.aider-chat-with-playwright
    unstable.opencode
    with-or
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

  # services.ollama = {
  #   enable = true;
  #   acceleration = "cuda";
  # };

  programs.java.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # Easy shell environments
  home-manager.users.dirakon.programs.direnv =
    {
      enable = true;
      enableFishIntegration = true;
      silent = true;
      nix-direnv.enable = true;
    };
}
