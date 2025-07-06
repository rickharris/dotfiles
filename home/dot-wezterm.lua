local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "catppuccin-macchiato"
config.front_end = "WebGpu"

-- config.font_size = 18
-- config.font = wezterm.font("LetterGothicMono Nerd Font Mono")

config.font_size = 15
config.font = wezterm.font("Maple Mono NF")
config.harfbuzz_features = {
  "cv01=1",
  "cv04=1",
  "ss01=1",
  "ss02=1",
  "ss03=1",
  "ss05=1",
}
config.line_height = 1.05

config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true

return config
