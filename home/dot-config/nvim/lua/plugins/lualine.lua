---@type LazySpec
return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      globalstatus = true,
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_b = {
        {
          "branch",
          icon = "",
        },
      },
      lualine_c = { "filename", "diagnostics" },
      lualine_x = { "diff", "filetype" },
    },
  },
  dependencies = { "mini.icons" },
}
