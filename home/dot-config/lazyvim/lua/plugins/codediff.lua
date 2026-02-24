local keys = {
  {
    "<leader>gd",
    "<cmd>CodeDiff<cr>",
    desc = "Diff view",
  },
  {
    "<leader>gD",
    "<cmd>CodeDiff main...<cr>",
    desc = "Diff view (merge base)",
  },
}

---@type LazySpec
return {
  "esmuellert/codediff.nvim",
  lazy = true,
  cmd = "CodeDiff",
  keys = keys,
  specs = {
    {
      "NeogitOrg/neogit",
      optional = true,
      ---@module 'neogit'
      ---@type NeogitConfig
      opts = { integrations = { codediff = true } },
    },
    {
      "folke/snacks.nvim",
      optional = true,
      keys = keys, -- Ensure default snacks keybindings get overridden by our keybindings
    },
  },
}
