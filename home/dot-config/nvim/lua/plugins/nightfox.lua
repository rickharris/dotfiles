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
        --- The default dawnfox yellow does not have enough contrast for my
        --- eyes. These values are the colors from the theme, shaded down by
        --- 0.25.
        yellow = {
          base = "#b07627",
          bright = "#b37e35",
          dim = "#a66c1b",
        },
      },
    },
    groups = {
      all = {
        --- Nightfox themes set `NormalFloat` to have a darker background color to contrast it to the standard background color, but
        --- float border and title have the normal background. This results in
        --- a weird two-tone theme for floating windows. I prefer to have
        --- NormalFloat, FloatBorder, and FloatTitle to all have matching
        --- styles.
        FloatBorder = {
          link = "NormalFloat",
        },
        FloatTitle = {
          link = "NormalFloat",
        },
      },
    },
  },
}
