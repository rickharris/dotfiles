--- @type LazySpec
return {
  "nvim-mini/mini.files",
  opts = {
    mappings = {
      -- Mirror oil.nvim mappings
      go_in = "",
      go_in_plus = "<cr>",
      go_out = "",
      go_out_plus = "-",
    },
    windows = {
      preview = false,
    },
  },
}
