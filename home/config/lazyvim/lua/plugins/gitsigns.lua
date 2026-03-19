--!strict

---@module 'lazy'
---@type LazySpec
return {
  "lewis6991/gitsigns.nvim",
  event = "LazyFile",
  ---@module 'gitsigns'
  ---@class (partial) Gitsigns.Config
  opts = {
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
      end

      map("n", "<leader>gb", function()
        gs.blame()
      end, "Blame Buffer")
    end,
  },
}
