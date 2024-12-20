return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },
  ---@module 'lazy'
  ---@type LazySpec
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
