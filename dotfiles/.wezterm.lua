local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Colors and fonts
local function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "tokyonight_storm"
  else
    return "dawnfox"
  end
end

wezterm.on("window-config-reloaded", function(window)
  local overrides = window:get_config_overrides() or {}
  local appearance = window:get_appearance()
  local scheme = scheme_for_appearance(appearance)
  if overrides.color_scheme ~= scheme then
    overrides.color_scheme = scheme
    window:set_config_overrides(overrides)
  end
end)
config.font = wezterm.font("LetterGothicMono Nerd Font Mono")
config.font_size = 18

-- Window customizations
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
-- config.window_background_opacity = 0.8
-- config.macos_window_background_blur = 50

return config
