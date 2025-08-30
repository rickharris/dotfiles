---@type LazySpec
return {
  {
    "NeogitOrg/neogit",
    cmd = {
      "Neogit",
      "NeogitCommit",
      "NeogitLogCurrent",
      "NeogitResetState",
    },
    keys = {
      { "<leader>gg", "<cmd>Neogit<CR>", desc = "Neogit" },
    },
    ---@module 'neogit'
    ---@type NeogitConfig
    opts = {
      signs = {
        -- { CLOSED, OPENED }
        hunk = { "", "" },
        item = { "", "" },
        section = { "", "" },
      },
    },
    dependencies = {
      "folke/snacks.nvim",
    },
  },
  { "nvim-lua/plenary.nvim", lazy = true },
}
