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
        "stylelint-language-server",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = function(_, opts)
      local stylelint_base_on_attach = vim.lsp.config.stylelint_lsp.on_attach

      return vim.tbl_deep_extend("force", opts, {
        servers = {
          --- @type vim.lsp.Config
          cssls = {},
          --- @type vim.lsp.Config
          cssmodules_ls = {
            settings = {
              capabilities = {
                definitionProvider = false,
              },
            },
          },
          --- @type vim.lsp.Config
          stylelint_lsp = {
            on_attach = function(client, bufnr)
              if not stylelint_base_on_attach then
                return
              end

              stylelint_base_on_attach(client, bufnr)
              vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                command = "LspStylelintFixAll",
              })
            end,
          },
        },
      })
    end,
  },
}
