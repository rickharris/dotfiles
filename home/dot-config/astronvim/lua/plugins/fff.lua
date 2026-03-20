--!strict

---@module 'lazy'
---@type LazySpec
return {
  {
    "dmtrKovalenko/fff.nvim",
    build = function() require("fff.download").download_or_build_binary() end,
    lazy = false, -- make fff initialize on startup
  },

  {
    "madmaxieee/fff-snacks.nvim",
    lazy = false, -- lazy loaded by design
    keys = {
      {
        "<Leader><Space>",
        function() require("fff-snacks").find_files() end,
        desc = "Find Files",
      },
    },
  },
}
