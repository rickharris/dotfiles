--- @type LazySpec
return {
  {
    "echasnovski/mini.files",
    version = "*",
    opts = {
      mappings = {
        synchronize = "<cr>",
      },
    },
    keys = {
      {
        "<leader>e",
        function()
          local mf = require("mini.files")
          if not mf.close() then
            mf.open(vim.api.nvim_buf_get_name(0), false)
          end
        end,
        mode = { "n" },
        desc = "Toggle File Explorer",
      },
    },
  },
}
