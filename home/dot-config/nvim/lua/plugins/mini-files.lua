--- @type LazySpec
return {
  {
    "echasnovski/mini.files",
    version = "*",
    opts = {
      windows = {
        preview = false,
      },
    },
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = "Open mini.files (Directory of Current File)",
      },
    },
  },
}
