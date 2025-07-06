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
    "williamboman/mason-lspconfig.nvim",
    optional = true,
    opts = {
      ensure_installed = {
        "eslint",
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
