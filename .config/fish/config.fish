function __fish_command_not_found_handler --on-event fish_command_not_found
    ~/bin/nix-command-not-found $argv
end


if status is-interactive

    # Commands to run in interactive sessions can go here
end
