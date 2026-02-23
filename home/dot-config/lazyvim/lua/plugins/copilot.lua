---@type LazySpec
return {
  "zbirenbaum/copilot.lua",
  optional = true,
  ---@class (partial) CopilotConfig
  opts = {
    copilot_node_command = vim.fn.expand("$HOME") .. "/.asdf/installs/nodejs/lts/bin/node",
  },
}
