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
      signs = {
        -- { CLOSED, OPENED }
        hunk = { "", "" },
        item = { "", "" },
        section = { "", "" },
      },
    },
  },
}
