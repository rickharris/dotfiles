---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      n = {
        -- Override the mini-files community plugin's <Leader>e mapping to open
        -- at the current file rather than the current working directory.
        ["<Leader>e"] = {
          function()
            local files = require "mini.files"
            local buf_name = vim.api.nvim_buf_get_name(0)
            local path = vim.fn.filereadable(buf_name) == 1 and buf_name or nil
            if not files.close() then files.open(path) end
          end,
          desc = "Explorer",
        },
      },
    },
  },
}
