local colorschemes = {
  dark = "tokyonight",
  light = "dawnfox",
}

---@param bg "dark" | "light"
local set_colorscheme = function(bg)
  vim.api.nvim_set_option_value("background", bg, {})
  vim.cmd("colorscheme " .. colorschemes[bg])
end

---@type LazySpec
return {
  "f-person/auto-dark-mode.nvim",
  event = "VeryLazy",
  opts = {
    update_interval = 1000,
    set_dark_mode = function()
      set_colorscheme("dark")
    end,
    set_light_mode = function()
      set_colorscheme("light")
    end,
  },
}
