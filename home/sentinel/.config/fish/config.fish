function __fish_command_not_found_handler --on-event fish_command_not_found
    ~/.scripts/nix-command-not-found $argv
end

if status is-interactive
    fastfetch
    zoxide init fish --cmd cd | source
end
