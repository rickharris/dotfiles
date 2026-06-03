---@type LazySpec
return {
  dir = vim.fn.expand("~/.config/nvim-shared"),
  name = "pr-reviews",
  event = "VeryLazy",
  dependencies = {
    "folke/snacks.nvim",
    "pwntester/octo.nvim",
    "nvim-lualine/lualine.nvim",
  },
  -- Put the shared dir on the runtimepath at startup so the lualine component's
  -- deferred require resolves regardless of lazy load order.
  init = function()
    vim.opt.runtimepath:append(vim.fn.expand("~/.config/nvim-shared"))
  end,
  config = function()
    require("pr_reviews").setup({})
  end,
  keys = {
    {
      "<leader>or",
      function()
        require("pr_reviews").pick()
      end,
      desc = "Review requests",
    },
  },
}
