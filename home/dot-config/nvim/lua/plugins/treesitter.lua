--- @type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  lazy = false,
  opts_extend = { "ensure_installed" },
  --- @module 'nvim-treesitter'
  --- @type TSConfig
  --- @diagnostic disable-next-line: missing-fields
  opts = {
    highlight = { enable = true },
    indent = { enable = true },
  },
}
