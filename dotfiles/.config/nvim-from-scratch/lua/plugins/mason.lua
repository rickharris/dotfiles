---@module "lazy"
---@type LazySpec
return {
  {
    "williamboman/mason.nvim",
    lazy = true,
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {},
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "lua-language-server", "stylua" },
    },
  },
}
