return {
  {
    "EdenEast/nightfox.nvim",
    -- Installed via community plugin
    optional = true,
    opts = {
      options = {
        modules = {
          neogit = false,
        },
        styles = {
          comments = "italic",
        },
      },
      specs = {
        dawnfox = {
          --- Make yellow more visible, hard to see by default.
          yellow = {
            base = "#b07627",
            bright = "#b37e35",
            dim = "#a66c1b",
          },
        },
        terafox = {
          -- Less white for text, more cyan
          fg0 = "cyan.bright",
          fg1 = "cyan",
          fg2 = "cyan.dim",
          syntax = {
            variable = "cyan.base",
          },
        },
      },
    },
  },
}
