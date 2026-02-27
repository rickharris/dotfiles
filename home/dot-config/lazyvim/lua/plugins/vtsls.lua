--!strict

---@module 'lazy'
---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  opts = {
    setup = {
      -- Disable vtsls formatting
      vtsls = function()
        Snacks.util.lsp.on({ name = "vtsls" }, function(_, client)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end)
      end,
    },
  },
}
