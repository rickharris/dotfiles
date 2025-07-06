---@type LazySpec
return {
  "NeogitOrg/neogit",
  cmd = "Neogit",
  keys = {
    { "<leader>g", desc = "Neogit" },
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
    "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
  },
}
