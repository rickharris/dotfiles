---@type LazySpec
return {
  "NeogitOrg/neogit",
  cmd = {
    "Neogit",
    "NeogitCommit",
    "NeogitLogCurrent",
    "NeogitResetState",
  },
  keys = {
    { "<leader>gg", "<cmd>Neogit<CR>", desc = "Neogit" },
    {
      "<leader>gl",
      "<cmd>NeogitLogCurrent<cr>",
      desc = "Log file",
      mode = { "n", "x" },
    },
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
    "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
  },
}
