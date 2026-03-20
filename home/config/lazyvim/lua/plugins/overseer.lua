--!strict

---@module 'lazy'
---@type LazySpec
return {
  {
    "catppuccin",
    optional = true,
    opts = {
      integrations = { overseer = true },
    },
  },
  {
    "stevearc/overseer.nvim",
    init = function()
      vim.cmd.cnoreabbrev("OS OverseerShell")
    end,
    cmd = {
      "OverseerOpen",
      "OverseerClose",
      "OverseerToggle",
      "OverseerRun",
      "OverseerShell",
      "OverseerTaskAction",
    },
    ---@module 'overseer'
    ---@type overseer.SetupOpts
    opts = {},
    -- stylua: ignore
    keys = {
      { "<leader>oo", "<cmd>OverseerRun<cr>",         desc = "Run task" },
      { "<leader>os", "<cmd>OverseerShell<cr>",       desc = "Run shell task" },
      { "<leader>ot", "<cmd>OverseerTaskAction<cr>",  desc = "Task action" },
      { "<leader>ow", "<cmd>OverseerToggle<cr>",      desc = "Task list" },
    },
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>o", group = "overseer" },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.consumers = opts.consumers or {}
      opts.consumers.overseer = require("neotest.consumers.overseer")
    end,
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      require("overseer").enable_dap()
    end,
  },
}
