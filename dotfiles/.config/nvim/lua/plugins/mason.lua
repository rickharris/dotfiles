return {
  {
    "williamboman/mason.nvim",
    version = "^1.0.0",
    opts = {
      ensure_installed = {
        "ast-grep",
        "css-lsp",
        "cssmodules-language-server",
        "css-variables-language-server",
        "prettierd",
        "stylelint",
        "stylelint-lsp",
      },
    },
  },
  { "mason-org/mason-lspconfig.nvim", version = "^1.0.0" },
}
