--!strict

---@class (partial) NeotestLazyOpts: neotest.Config
---@field lazy_adapters table<string, table> | nil
---@field lazy_consumers table<string, string> | nil

---@type LazySpec
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
    },
    ---@param opts NeotestLazyOpts
    config = function(_, opts)
      opts.adapters = opts.adapters or {}
      if opts.lazy_adapters then
        for name, config in pairs(opts.lazy_adapters) do
          table.insert(opts.adapters, require(name)(config))
        end
      end

      opts.consumers = opts.consumers or {}
      if opts.lazy_consumers then
        for key, name in pairs(opts.lazy_consumers) do
          opts.consumers[key] = require(name)
        end
      end

      require("neotest").setup(opts)
    end,
    keys = {
      {
        "<leader>tt",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Test current file",
      },
      {
        "<leader>ta",
        function()
          require("neotest").run.run(vim.uv.cwd())
        end,
        desc = "Test all",
      },
      {
        "<leader>tn",
        function()
          require("neotest").run.run()
        end,
        desc = "Run nearest test",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Test summary",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true, auto_close = true })
        end,
        desc = "Test output",
      },
      {
        "<leader>tS",
        function()
          require("neotest").run.stop()
        end,
        desc = "Stop",
      },
    },
  },
  { "nvim-lua/plenary.nvim", lazy = true },
}
