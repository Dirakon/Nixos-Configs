function __fish_command_not_found_handler --on-event fish_command_not_found
    ~/bin/nix-command-not-found $argv
end


function its-nixxing-time
    sudo nixos-rebuild switch --flake ~/.dotfiles $argv
end

function nvidia-offload
    set -x __NV_PRIME_RENDER_OFFLOAD 1
    set -x __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0
    set -x __GLX_VENDOR_LIBRARY_NAME nvidia
    set -x __VK_LAYER_NV_optimus NVIDIA_only
    exec $argv
end


if status is-interactive

    # Commands to run in interactive sessions can go here
end
