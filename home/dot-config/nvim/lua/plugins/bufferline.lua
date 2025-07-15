return {
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    ---@module 'bufferline'
    ---@class (partial) bufferline.Config
    opts = {
      options = {
        always_show_bufferline = false,
        diagnostics = "nvim_lsp",
      },
    },
    config = function(_, opts)
      -- Defer requiring until module is loaded rather than using require
      -- inside of `opts` function.
      ---@class (partial) bufferline.Config
      local pin_icon_override = {
        options = {
          groups = {
            items = {
              require("bufferline.groups").builtin.pinned:with({
                icon = "󰐃 ",
              }),
            },
          },
        },
      }
      require("bufferline").setup(
        vim.tbl_deep_extend("keep", opts, pin_icon_override)
      )
    end,
    keys = {
      {
        "<leader>bo",
        "<cmd>BufferLineCloseOthers<cr>",
        desc = "Close other buffers",
      },
      {
        "<leader>bp",
        "<cmd>BufferLineTogglePin<cr>",
        desc = "Pin buffer",
      },
      {
        "<leader>bu",
        "<cmd>BufferLineGroupClose ungrouped<cr>",
        desc = "Close unpinned buffers",
      },
      {
        "<leader>1",
        "<cmd>BufferLineGoToBuffer 1<cr>",
        desc = "Go to first buffer",
      },
      {
        "<leader>2",
        "<cmd>BufferLineGoToBuffer 2<cr>",
        desc = "Go to second buffer",
      },
      {
        "<leader>3",
        "<cmd>BufferLineGoToBuffer 3<cr>",
        desc = "Go to third buffer",
      },
      {
        "<leader>4",
        "<cmd>BufferLineGoToBuffer 4<cr>",
        desc = "Go to fourth buffer",
      },
    },
  },
}
