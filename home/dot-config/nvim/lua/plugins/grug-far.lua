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
        ---@type grug.far.OptionsOverride
        local opts = {}

        if vim.bo.filetype == "snacks_dashboard" then
          -- When triggered from the dashboard, open grug-far in the current window.
          opts.windowCreationCommand = ""
        end

        require("grug-far").open(opts)
      end,
      mode = { "n", "v" },
      desc = "Search and Replace",
    },
  },
}
