--- @type LazySpec
return {
  {
    "neovim/nvim-lspconfig",
    config = function(_, opts)
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        },
      })

      for server, server_opts in pairs(opts.servers) do
        vim.lsp.config(server, server_opts)
      end

      vim.lsp.enable(vim.tbl_keys(opts.servers))
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          if
            client
            and client:supports_method(
              vim.lsp.protocol.Methods.textDocument_definition,
              event.buf
            )
          then
            vim.keymap.set(
              "n",
              "gd",
              vim.lsp.buf.definition,
              { desc = "Go to definition" }
            )
          end
        end,
      })
    end,
    dependencies = {
      { "j-hui/fidget.nvim", opts = {} },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts_extend = { "ensure_installed" },
    opts = {},
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
  },
}
