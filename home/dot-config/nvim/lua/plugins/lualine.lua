---@type LazySpec
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      globalstatus = true,
      disabled_filetypes = { statusline = { "snacks_dashboard" } },
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
}
