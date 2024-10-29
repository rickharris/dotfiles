--!strict

---@class Colorschemes
---@field dark string
---@field light string

---@type Colorschemes
local colorschemes = {
  dark = "terafox",
  light = "dawnfox",
}

---@param bg "dark" | "light"
local set_colorscheme = function(bg)
  vim.api.nvim_set_option_value("background", bg, {})
  vim.cmd("colorscheme " .. colorschemes[bg])
end

return {
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      flavour = "macchiato",
    },
  },
  {
    "EdenEast/nightfox.nvim",
    opts = {
      options = {
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
    opts = {
      style = "storm",
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = colorschemes.light,
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
