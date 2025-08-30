--!strict

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
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
      },
    },
  },
  {

    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-jest",
    },
    ---@type NeotestLazyOpts
    opts = {
      lazy_adapters = {
        ["neotest-jest"] = {},
      },
    },
  },
}
