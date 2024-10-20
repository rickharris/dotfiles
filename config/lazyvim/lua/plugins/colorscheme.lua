return {
  { "EdenEast/nightfox.nvim" },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      dark_variant = "moon",
    },
  },
  {
    "maxmx03/solarized.nvim",
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
    "cormacrelf/dark-notify",
    lazy = false,
    priority = 1000,
    config = function()
      require("dark_notify").run({
        schemes = {
          dark = {
            bg = "dark",
            colorscheme = "tokyonight-storm",
          },
          light = {
            bg = "light",
            colorscheme = "solarized",
          },
        },
      })
    end,
  },
}
