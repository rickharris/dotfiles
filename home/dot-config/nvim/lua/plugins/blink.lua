---@type LazySpec
return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  dependencies = { "rafamadriz/friendly-snippets" },
  version = "1.*",
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    completion = { documentation = { auto_show = true } },
    fuzzy = {
      implementation = "prefer_rust",
    },
  },
  opts_extend = { "sources.default" },
}
