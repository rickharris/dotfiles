---@type LazySpec
return {
  "olimorris/codecompanion.nvim",
  cmd = {
    "CodeCompanion",
    "CodeCompanionActions",
    "CodeCompanionCmd",
    "CodeCompanionChat",
  },
  keys = {
    {
      "<C-a>",
      "<cmd>CodeCompanionActions<cr>",
      mode = { "n", "v" },
      noremap = true,
      silent = true,
    },
    {
      "<LocalLeader>a",
      "<cmd>CodeCompanionChat Toggle<cr>",
      mode = { "n", "v" },
      noremap = true,
      silent = true,
    },
    {
      "ga",
      "<cmd>CodeCompanionChat Add<cr>",
      mode = "v",
      noremap = true,
      silent = true,
    },
  },
  opts = {
    interactions = {
      chat = {
        adapter = {
          name = "copilot",
          model = "claude-sonnet-4.6",
        },
      },
      inline = {
        adapter = {
          name = "copilot",
          model = "claude-sonnet-4.6",
        },
      },
    },
  },
  dependencies = {
    "zbirenbaum/copilot.lua",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "codecompanion" },
      opts = {},
    },
  },
  specs = {
    {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        ensure_installed = {
          "markdown",
          "markdown_inline",
          "yaml",
        },
      },
    },
  },
}
