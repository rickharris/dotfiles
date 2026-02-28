--!strict

---@module 'lazy'
---@type LazySpec
return {
  "zbirenbaum/copilot.lua",
  optional = true,
  ---@module "copilot"
  ---@class (partial) CopilotConfig
  opts = {
    nes = {
      enabled = true,
      auto_trigger = true,
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
