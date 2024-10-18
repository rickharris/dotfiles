local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Colors and fonts
config.font = wezterm.font("LetterGothicMono Nerd Font")
config.font_size = 18
config.color_scheme = "tokyonight_storm"

-- Window customizations
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.8
config.macos_window_background_blur = 50

return config
