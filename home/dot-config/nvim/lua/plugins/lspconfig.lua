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
        local has_blink, blink = pcall(require, "blink.cmp")

        if has_blink then
          server_opts.capabilities =
            blink.get_lsp_capabilities(server_opts.capabilities)
        end

        vim.lsp.config(server, server_opts)
      end

      vim.lsp.enable(vim.tbl_keys(opts.servers))
    end,
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
