local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.front_end = "WebGpu"
config.font = wezterm.font("Maple Mono")
config.harfbuzz_features = { "cv01=1", "cv04=1", "ss02=1", "ss05=1" }
config.font_size = 15
config.color_scheme = "terafox"
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true

return config
