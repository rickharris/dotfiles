---@module 'lazy'
---@type LazySpec
return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>e", false },
      { "<leader>E", false },
    },
  },
  {
    "stevearc/oil.nvim",
    keys = {
      {
        "<leader>e",
        function()
          require("oil").toggle_float()
        end,
        desc = "Explorer Oil (cwd)",
      },
      {
        "<leader>E",
        function()
          require("oil").toggle_float(LazyVim.root())
        end,
        desc = "Explorer Oil (Root Dir)",
      },
    },
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      default_file_explorer = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
      },
    },
  },
}
