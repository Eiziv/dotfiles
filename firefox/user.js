// Restore previous session
user_pref("browser.startup.page", 3);

// Middle mouse scroll
user_pref("general.autoScroll", true);

// Enable browser toolbox
user_pref("devtools.chrome.enabled", true);
user_pref("devtools.debugger.remote-enabled", true);

user_pref("browser.sessionstore.resume_from_crash", true);
user_pref("general.aboutConfig.enable", true);
user_pref("middlemouse.paste", false);
user_pref("sidebar.animation.enabled", false);
// user_pref("image.jxl.enabled", true);
user_pref("devtools.cache.disabled", true);
user_pref("devtools.netmonitor.persistlog", true);
user_pref("devtools.webconsole.persistlog", true);
user_pref("devtools.webconsole.timestampMessages", true);

user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Hardware video decoding on NVIDIA via VA-API (libva-nvidia-driver).
// Firefox blocks NVIDIA for this by default; needs NVD_BACKEND and
// MOZ_DISABLE_RDD_SANDBOX from hyprland.lua as well.
user_pref("media.hardware-video-decoding.force-enabled", true);
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("widget.dmabuf.force-enabled", true);
