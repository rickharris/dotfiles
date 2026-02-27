--!strict

---@module 'lazy'
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
      "<leader>sr",
      function()
        ---@class grug.far.OptionsOverride
        local opts = {
          visualSelectionUsage = "operate-within-range",
        }

        if vim.bo.filetype == "snacks_dashboard" then
          -- When triggered from the dashboard, open grug-far in the current window.
          opts.windowCreationCommand = ""
        end

        require("grug-far").open(opts)
      end,
      mode = { "n", "x" },
      desc = "Search and Replace",
    },
  },
}
