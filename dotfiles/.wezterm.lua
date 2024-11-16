local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.front_end = "WebGpu"
config.font = wezterm.font("LetterGothicMono Nerd Font Mono")
config.font_size = 16
config.color_scheme = "catppuccin-macchiato"
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true

return config
