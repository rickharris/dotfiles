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
      lualine_x = {
        -- Deferred require (render-time) so this is safe regardless of lazy
        -- load order.
        {
          function()
            return require("pr_reviews").statusline()
          end,
        },
        "diff",
        "filetype",
      },
    },
  },
}
