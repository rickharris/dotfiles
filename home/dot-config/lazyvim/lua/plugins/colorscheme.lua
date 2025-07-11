--!strict

---@class Colorschemes
---@field dark string
---@field light string
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
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    ---@module "catppuccin"
    ---@type CatppuccinOptions
    opts = {
      flavour = "macchiato",
      custom_highlights = function()
        local tokyo = require("tokyonight.colors.moon")
        local util = require("tokyonight.util")
        local visual_bg = util.blend_bg(tokyo.blue0, 0.5)

        return {
          Comment = {
            fg = tokyo.comment,
          },
          Visual = {
            bg = visual_bg,
            style = {},
          },
        }
      end,
    },
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = true,
    opts = {
      options = {
        modules = {
          neogit = false,
        },
        styles = {
          comments = "italic",
        },
      },
      palettes = {
        dawnfox = {
          yellow = {
            base = "#b07627",
            bright = "#b37e35",
            dim = "#a66c1b",
          },
        },
      },
    },
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    opts = {
      light_variant = "dawn",
      dark_variant = "moon",

      styles = {
        italic = false,
      },

      highlight_groups = {
        Comment = { italic = true },
      },
    },
  },
  {
    "maxmx03/solarized.nvim",
    lazy = true,
    opts = {
      palette = "solarized", -- solarized (default) | selenized
      variant = "winter", -- "spring" | "summer" | "autumn" | "winter" (default)

      styles = {
        comments = { italic = true, bold = false },
        visual = { bold = false },
      },

      on_highlights = function(colors)
        local groups = {
          -- Classic Solarized highlighting
          -- Visual = {
          --   bg = vim.o.background == "light" and colors.base1 or colors.base01,
          --   fg = vim.o.background == "light" and colors.base3 or colors.base03,
          --   bold = false,
          -- },
          -- More subtle visual highlight
          Visual = {
            bg = vim.o.bg == "light" and colors.base2 or colors.base02,
            fg = "NONE",
            bold = false,
          },
        }

        return groups
      end,
    },
  },
  {
    "tokyonight.nvim",
  },
  {
    "zenbones-theme/zenbones.nvim",
    -- Optionally install Lush. Allows for more configuration or extending the colorscheme
    -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
    -- In Vim, compat mode is turned on as Lush only works in Neovim.
    dependencies = "rktjmp/lush.nvim",
    lazy = true,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = colorschemes.dark,
    },
  },
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        set_colorscheme("dark")
      end,
      set_light_mode = function()
        set_colorscheme("light")
      end,
    },
  },
}
