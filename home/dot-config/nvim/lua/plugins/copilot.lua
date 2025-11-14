---@type LazySpec
return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "BufReadPost",
  ---@module 'copilot'
  ---@class (partial) CopilotConfig
  config = {
    copilot_node_command = vim.fn.expand("$HOME")
      .. "/.asdf/installs/nodejs/lts/bin/node",
  },
}
