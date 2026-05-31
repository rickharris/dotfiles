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
        "oxlint",
        "oxfmt",
        "vtsls",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    optional = true,
    init = function() end,
    opts = function(_, opts)
      local oxlint_base_on_attach = vim.lsp.config.oxlint.on_attach
      return vim.tbl_deep_extend("force", opts, {
        servers = {
          denols = {
            workspace_required = true,
            root_markers = { "deno.json", "deno.jsonc" },
          },
          eslint = {},
          graphql = {},
          oxfmt = {},
          oxlint = {
            on_attach = function(client, bufnr)
              if not oxlint_base_on_attach then
                return
              end

              oxlint_base_on_attach(client, bufnr)
              vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                command = "LspOxlintFixAll",
              })
            end,
          },
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
      })
    end,
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
