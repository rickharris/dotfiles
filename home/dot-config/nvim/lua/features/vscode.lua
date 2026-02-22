if not vim.g.vscode then
  return {}
end

local Config = require("lazy.core.config")
local vscode = require("vscode")
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
---@param plugin LazyPlugin
---@return boolean
Config.options.defaults.cond = function(plugin)
  ---`vscode` is not part of Lazyplugin spec, but plugins in this config can
  ---add it if the plugin can and should be available in vscode.
  ---@diagnostic disable-next-line: undefined-field
  return plugin.vscode
end
vim.g.snacks_animate = false

-- Add some vscode specific keymaps
vim.api.nvim_create_autocmd("User", {
  callback = function()
    -- VSCode-specific keymaps for search and navigation
    vim.keymap.set("n", "<leader><space>", "<cmd>Find<cr>")
    vim.keymap.set("n", "<leader>s", function()
      vscode.call("workbench.action.findInFiles")
    end)

    -- Navigate VSCode tabs like lazyvim buffers
    vim.keymap.set("n", "[b", function()
      vscode.call("workbench.action.previousEditor")
    end)
    vim.keymap.set("n", "]b", function()
      vscode.call("workbench.action.nextEditor")
    end)

    vim.keymap.set("n", "[d", function()
      vscode.call("editor.action.marker.prev")
    end)
    vim.keymap.set("n", "]d", function()
      vscode.call("editor.action.marker.next")
    end)
  end,
})

return {
  {
    "snacks.nvim",
    opts = {
      bigfile = { enabled = false },
      dashboard = { enabled = false },
      indent = { enabled = false },
      input = { enabled = false },
      notifier = { enabled = false },
      picker = { enabled = false },
      quickfile = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { highlight = { enable = false } },
  },
}
