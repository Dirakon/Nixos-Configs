function __fish_command_not_found_handler --on-event fish_command_not_found
    ~/.scripts/nix-command-not-found $argv
end

if test (tty) = "/dev/tty1"
    while true;
        sleep 10
        cat /sys/class/drm/card*/*HDMI*/status |grep '^connected'
        if test $status -eq 0 
            exec uwsm start /run/current-system/sw/bin/Hyprland
        end
    end
end

if status is-interactive
    fastfetch
    zoxide init fish --cmd cd | source
end
