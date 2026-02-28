--!strict

---@module 'lazy'
---@type LazySpec
return {
  "olimorris/codecompanion.nvim",
  version = "^18.0.0",
  init = function()
    vim.cmd([[cab cc CodeCompanion]])
  end,
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
    extensions = {
      history = {
        enabled = true,
      },
    },
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
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "codecompanion" },
      opts = {},
    },
    "ravitemer/codecompanion-history.nvim",
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
