return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        css = { "prettier", "stylelint" },
        sh = { "shfmt", "shellcheck" },
      },
    },
  },
}
