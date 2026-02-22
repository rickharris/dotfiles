return {
  "esmuellert/codediff.nvim",
  cmd = "CodeDiff",
  keys = {
    {
      "<leader>gd",
      "<cmd>CodeDiff<cr>",
      desc = "Diff view",
    },
  },
  specs = {
    {
      "NeogitOrg/neogit",
      optional = true,
      ---@module 'neogit'
      ---@type NeogitConfig
      opts = { integrations = { codediff = true } },
    },
  },
}
