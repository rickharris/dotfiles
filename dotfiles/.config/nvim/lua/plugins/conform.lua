return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        css = { "prettier", "stylelint" },
        sh = { "shellcheck" },
      },
    },
  },
}
