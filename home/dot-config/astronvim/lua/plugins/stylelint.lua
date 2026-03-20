---@type LazySpec
return {
  {
    "williamboman/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed or {}, { "stylelint" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed or {}, { "stylelint-lsp" })
    end,
  },
  {
    "echasnovski/mini.icons",
    optional = true,
    opts = function(_, opts)
      opts.file = opts.file or {}
      local stylelint_files = {
        -- Supported but not forever
        ".stylelintignore",
        ".stylelintrc.js",
        ".stylelintrc.mjs",
        ".stylelintrc.cjs",
        ".stylelintrc",
        ".stylelintrc.yml",
        ".stylelintrc.yaml",
        ".stylelintrc.json",
        -- Preferred
        "stylelint.config.cjs",
        "stylelint.config.js",
        "stylelint.config.mjs",
      }
      for _, filename in ipairs(stylelint_files) do
        opts.file[filename] = { glyph = "v", hl = "MiniIconsBlue" }
      end
    end,
  },
}
