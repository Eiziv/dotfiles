hl.window_rule({
    match = {
        class = "gtkgreet",
    },
    float = true,
})

hl.monitor({
    output = "HDMI-A-2",
    mode = "2560x1440@280",
    position = "0x0",
    scale = 1,
    vrr = 0,
})

hl.monitor({
    output = "DP-1",
    disabled = true,
})

hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
    general = {
        border_size = 2,
        gaps_in = 5,
        gaps_out = 17,
        layout = "dwindle",
        col = {
            active_border = "rgb(aaffff)",
            inactive_border = "rgba(00000000)",
        },
    },
    decoration = {
        rounding = 10,
        blur = {
            enabled = true,
            size = 9,
            passes = 3,
            new_optimizations = true,
        },
        shadow = {
            enabled = false,
            render_power = 3,
            range = 4,
            color = "rgba(1a1a1aee)",
        },
    },
    input = {
        kb_layout = "no",
        follow_mouse = 1,
        sensitivity = 0,
        accel_profile = "flat",
    },
    debug = {
        disable_logs = false,
    },
})

hl.on("hyprland.start", function()
    hl.exec_cmd("gtkgreet -c start-hyprland -s /etc/greetd/style.css; hyprctl dispatch exit")
    hl.exec_cmd("hyprpaper -c /etc/greetd/hyprpaper.conf")
    hl.exec_cmd("kitty")
end)
