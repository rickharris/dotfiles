--!strict
--- @type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = {
      ensure_installed = {
        "html",
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = {
      ensure_installed = {
        "html-lsp",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        html = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
      formatters_by_ft = {
        html = { "prettier" },
      },
    },
  },
}
