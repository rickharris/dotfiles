return {
  "sindrets/diffview.nvim",
  cmd = {
    "DiffviewClose",
    "DiffviewFileHistory",
    "DiffviewFocusFiles",
    "DiffviewLog",
    "DiffviewOpen",
    "DiffviewRefresh",
    "DiffviewToggleFiles",
  },
  ---@module 'diffview'
  ---@type DiffviewConfig
  opts = {
    enhanced_diff_hl = true,
    keymaps = {
      file_panel = {
        {
          "n",
          "<leader>e",
          function()
            require("diffview.actions").focus_entry()
          end,
          { desc = "Focus entry" },
        },
      },
    },
  },
  keys = {
    {
      "<leader>gd",
      "<cmd>DiffviewOpen<cr>",
      desc = "Diff view",
    },
    {
      "<leader>gh",
      "<cmd>:DiffviewFileHistory %<cr>",
      mode = { "n", "x" },
      desc = "File history",
    },
  },
  specs = {
    {
      "NeogitOrg/neogit",
      optional = true,
      opts = { integrations = { diffview = true } },
    },
  },
}
