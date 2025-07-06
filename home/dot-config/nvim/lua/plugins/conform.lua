--- @type LazySpec
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      default_format_opts = {
        lsp_format = "fallback",
      },
      format_on_save = { timeout_ms = 500 },
    },
    init = function()
      -- If you want the formatexpr, here is the place to set it
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts_extend = { "ensure_installed" },
    opts = {},
    dependencies = {
      "mason-org/mason.nvim",
    },
  },
}
