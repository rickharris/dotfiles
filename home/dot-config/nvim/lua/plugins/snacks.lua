---@type LazySpec
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@module 'snacks'
  ---@type snacks.Config
  opts = {
    dashboard = {
      enabled = true,
    },
    indent = {
      enabled = true,
    },
    notifier = {
      enabled = true,
    },
    picker = {
      enabled = true,
      sources = {
        files = {
          hidden = true,
        },
      },
    },
    statuscolumn = {
      enabled = true,
    },
    terminal = {
      win = {
        position = "right",
      },
    },
  },
  keys = {
    {
      "<leader><space>",
      function()
        Snacks.picker.smart()
      end,
      desc = "Smart Find Files",
    },
    {
      "<leader>go",
      function()
        Snacks.gitbrowse()
      end,
      mode = { "n", "x" },
      desc = "Git Browse (open)",
    },
    {
      "<leader>gy",
      function()
        Snacks.gitbrowse({
          open = function(url)
            vim.fn.setreg("+", url)
          end,
          notify = false,
          what = "permalink",
        })
      end,
      mode = { "n", "x" },
      desc = "Git Browse (copy)",
    },
    {
      "<c-/>",
      function()
        Snacks.terminal()
      end,
      desc = "Toggle Terminal",
    },
    {
      "<c-/>",
      "<cmd>close<cr>",
      mode = "t",
      desc = "Hide Terminal",
    },
  },
}
