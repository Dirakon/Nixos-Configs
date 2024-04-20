function toggle_fullscreen_hyprland()
    mp.command_native_async({
        name = "subprocess",
        playback_only = false,
        capture_stdout = true,
        args = { "hyprctl", "dispatch", "fullscreen" },
    })
    mp.commandv("cycle", "fullscreen")
end

function exit_fullscreen_hyprland()
    if mp.get_property_bool("fullscreen") == true then
        mp.set_property("fullscreen", "no")
        mp.command_native_async({
            name = "subprocess",
            playback_only = false,
            capture_stdout = true,
            args = { "hyprctl", "dispatch", "fullscreen" },
        })
    end
end

function on_focused_change(name, value)
    if value == true then
        mp.register_script_message("toggle_fullscreen_hyprland", toggle_fullscreen_hyprland)
        mp.register_script_message("exit_fullscreen_hyprland", exit_fullscreen_hyprland)
    else
        mp.unregister_script_message("toggle_fullscreen_hyprland")
        mp.unregister_script_message("exit_fullscreen_hyprland")
    end
end

mp.observe_property("focused", "bool", on_focused_change)
