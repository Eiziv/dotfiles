-- gtkgreet runs as a full-screen layer (-l); blur the wallpaper behind it so the
-- login screen looks like hyprlock (blur 5/2 + dim from style.css).
hl.layer_rule({
    match = {
        namespace = "gtk-layer-shell",
    },
    blur = true,
    ignore_alpha = 0,
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

-- Same cursor as the desktop session. The greeter user has no settings of its
-- own, so without this Hyprland falls back to the default (Adwaita) cursor.
-- gtkgreet's own window reads GNOME's cursor setting instead; that default comes
-- from greetd/99_greeter-cursor.gschema.override in /usr/share/glib-2.0/schemas.
hl.env("XCURSOR_THEME", "BreezeX-Black")
hl.env("XCURSOR_SIZE", "28")

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
            size = 5,
            passes = 2,
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
    hl.exec_cmd("gtkgreet -l -c 'uwsm start hyprland-uwsm.desktop; hyprctl dispatch exit' -s /etc/greetd/style.css")
    hl.exec_cmd("hyprpaper -c /etc/greetd/hyprpaper.conf")
    hl.exec_cmd("kitty")
end)
