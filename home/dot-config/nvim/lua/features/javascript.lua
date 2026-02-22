--!strict

--- @type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = {
      ensure_installed = {
        "graphql",
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
        "deno",
        "eslint-lsp",
        "graphql-language-service-cli",
        "vtsls",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        denols = {
          workspace_required = true,
          root_markers = { "deno.json", "deno.jsonc" },
        },
        eslint = {},
        graphql = {},
        vtsls = {
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
          settings = {
            vtsls = {
              autoUseWorkspaceTsdk = true,
            },
          },
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
