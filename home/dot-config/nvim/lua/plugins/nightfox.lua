---@type LazySpec
return {
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
}
