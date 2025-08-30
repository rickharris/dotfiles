---@type LazySpec
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@module 'snacks'
  ---@type snacks.Config
  opts = {
    dashboard = {
      preset = {
        keys = {
          {
            desc = "Find files",
            icon = " ",
            label = "SPC SPC",
            action = "<leader><leader>",
          },
          {
            desc = "Search and replace",
            icon = " ",
            label = "SPC s",
            action = "<leader>s",
          },
          {
            desc = "Git",
            icon = " ",
            label = "SPC gg",
            action = "<leader>gg",
          },
        },
      },
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
      "<leader>/",
      function()
        Snacks.picker.grep()
      end,
      desc = "Grep",
    },
    {
      "<leader>bd",
      function()
        Snacks.bufdelete()
      end,
      desc = "Delete buffer",
    },
    {
      "<leader>be",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Buffer explorer",
    },
    {
      "<leader>fi",
      function()
        Snacks.picker.icons()
      end,
      desc = "Find Icon",
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
  specs = {
    {
      "akinsho/bufferline.nvim",
      optional = true,
      ---@module 'bufferline'
      ---@class (partial) bufferline.Config
      opts = {
        options = {
          close_command = function(n)
            Snacks.bufdelete(n)
          end,
        },
      },
    },
  },
}
