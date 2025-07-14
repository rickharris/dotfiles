--!strict
--- @type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = {
      ensure_installed = {
        "css",
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = {
      ensure_installed = {
        "css-lsp",
        "cssmodules-language-server",
        "stylelint-lsp",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        cssls = {},
        cssmodules_ls = {
          settings = {
            capabilities = {
              definitionProvider = false,
            },
          },
        },
        stylelint_lsp = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
      formatters_by_ft = {
        css = { "stylelint", "prettier" },
      },
    },
  },
}
