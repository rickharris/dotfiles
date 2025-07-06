--- @type LazySpec
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  --- @module 'snacks'
  --- @type snacks.Config
  opts = {
    picker = {
      sources = {
        files = {
          hidden = true,
        },
      },
    },
  },
  keys = {
    {
      "<leader><space>",
      function()
        Snacks.picker.smart()
      end,
      desc = "Smart Find Files",
    },
  },
}
