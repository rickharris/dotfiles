--!strict

---@module 'lazy'
---@type LazySpec
return {
  "zbirenbaum/copilot.lua",
  optional = true,
  opts = {
    nes = {
      enabled = true,
      keymap = {
        accept_and_goto = "<tab>",
        accept = false,
        dismiss = "<Esc>",
      },
    },
  },
  dependencies = {
    {
      "copilotlsp-nvim/copilot-lsp",
      init = function()
        vim.g.copilot_nes_debounce = 500
      end,
    },
  },
}
