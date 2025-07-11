--- @type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = {
      ensure_installed = {
        "javascript",
        "jsdoc",
        "tsx",
        "typescript",
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = {
      ensure_installed = {
        "eslint-lsp",
        "vtsls",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        eslint = {},
        vtsls = {
          settings = {
            javascript = {
              format = false,
            },
            typescript = {
              format = false,
            },
          },
        },
      },
    },
  },
}
