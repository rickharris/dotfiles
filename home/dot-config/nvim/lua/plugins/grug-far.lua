---@type LazySpec
return {
  "MagicDuck/grug-far.nvim",
  cmd = { "GrugFar", "GrugFarWithin" },
  ---@class (partial) grug.far.Options
  opts = {
    transient = true,
  },
  keys = {
    {
      "<leader>s",
      function()
        local mode = vim.fn.mode()
        if mode == "v" or mode == "V" then
          require("grug-far").with_visual_selection()
        else
          require("grug-far").open()
        end
      end,
      mode = { "n", "v" },
      desc = "Search and Replace",
    },
  },
}
