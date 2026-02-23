---@type LazySpec
return {
  {
    "yetone/avante.nvim",
    ---@module 'avante'
    ---@type avante.Config
    opts = {
      provider = "copilot",
      providers = {
        copilot = {
          model = "claude-sonnet-4.6",
        },
      },
    },
  },
}
