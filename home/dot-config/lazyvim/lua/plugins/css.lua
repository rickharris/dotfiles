--!strict

---@module 'lazy'
---@type LazySpec
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
    "mason-org/mason.nvim",
    optional = true,
    opts = {
      ensure_installed = {
        "css-lsp",
        "cssmodules-language-server",
        "css-variables-language-server",
        "stylelint-lsp",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        cssls = {
          init_options = {
            provideFormatter = false,
          },
        },
        cssmodules_ls = {
          settings = {
            capabilities = {
              definitionProvider = false,
            },
          },
        },
        css_variables = {},
        stylelint_lsp = {
          settings = {
            stylelintplus = {
              autoFixOnFormat = true,
              autoFixOnSave = true,
            },
          },
        },
      },
    },
  },
}
