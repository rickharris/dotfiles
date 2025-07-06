--- @type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  version = "*",
  build = ":TSUpdate",
  cmd = { "TSUpdateSync", "TSUpdate", "TSInstall", "TSConfigInfo" },
  opts_extend = { "ensure_installed" },
  --- @module 'nvim-treesitter'
  --- @type TSConfig
  --- @diagnostic disable-next-line: missing-fields
  opts = {
    highlight = { enable = true },
    indent = { enable = true },
  },
  ---@param opts TSConfig
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
