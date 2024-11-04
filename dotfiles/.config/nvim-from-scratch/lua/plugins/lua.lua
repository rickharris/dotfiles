return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VimEnter",
    opts = {
      ensure_installed = { "stylua" },
    },
  },
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    },
  },
}
