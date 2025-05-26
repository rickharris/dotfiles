return {
  "neovim/nvim-lspconfig",
  opts = {
    setup = {
      -- Disable vtsls formatting
      vtsls = function()
        LazyVim.lsp.on_attach(function(client)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end, "vtsls")
      end,
    },
  },
}
