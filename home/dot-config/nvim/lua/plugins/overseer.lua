--!strict

local run_latest_task_action = function(action)
  local overseer = require("overseer")
  local tasks = overseer.list_tasks({ recent_first = true })
  if vim.tbl_isempty(tasks) then
    vim.notify("No tasks found", vim.log.levels.WARN)
  else
    overseer.run_action(tasks[1], action)
  end
end

---@type LazySpec
return {
  {
    "stevearc/overseer.nvim",
    cmd = {
      "OverseerOpen",
      "OverseerClose",
      "OverseerToggle",
      "OverseerSaveBundle",
      "OverseerLoadBundle",
      "OverseerDeleteBundle",
      "OverseerRunCmd",
      "OverseerRun",
      "OverseerInfo",
      "OverseerBuild",
      "OverseerQuickAction",
      "OverseerTaskAction",
      "OverseerClearCache",
    },
    keys = {
      { "<leader>rr", "<cmd>OverseerRun<cr>", desc = "Run task" },
      {
        "<leader>re",
        function()
          run_latest_task_action("restart")
        end,
        desc = "Re-run latest task",
      },
      { "<leader>rt", "<cmd>OverseerToggle left<cr>", desc = "Task list" },
      {
        "<leader>ro",
        function()
          run_latest_task_action("open vsplit")
        end,
        desc = "Output from latest task",
      },
    },
    opts = {},
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    ---@type NeotestLazyOpts
    opts = {
      lazy_consumers = {
        overseer = "neotest.consumers.overseer",
      },
    },
  },
}
