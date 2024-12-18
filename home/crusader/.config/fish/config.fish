function __fish_command_not_found_handler --on-event fish_command_not_found
    ~/.scripts/nix-command-not-found $argv
end

function its-nixxing-time
    ~/.dotfiles/scripts/update_and_switch.sh $argv
end


if status is-interactive
and not set -q TMUX
    exec tmux
end

if status is-interactive
    fastfetch
    zoxide init fish --cmd cd | source
end
