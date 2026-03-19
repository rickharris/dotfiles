--!strict

---@module 'lazy'
---@type LazySpec
return {
  {
    "NeogitOrg/neogit",
    lazy = true,
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
      disable_signs = true, -- Fold signs are already handled by Snacks' statuscolumn.
    },
  },
}
