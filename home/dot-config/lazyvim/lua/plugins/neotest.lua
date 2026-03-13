--!strict

---@module 'lazy'
---@type LazySpec
return {
  { "nvim-neotest/neotest-jest", lazy = true },
  {
    "nvim-neotest/neotest",
    optional = true,
    keys = {
      {
        "<leader>to",
        function()
          require("neotest").output.open({
            enter = true,
            open_win = function()
              local pad = 4
              return vim.api.nvim_open_win(0, false, {
                relative = "editor",
                width = vim.o.columns - pad * 2,
                height = vim.o.lines - pad,
                row = 0,
                col = pad,
                style = "minimal",
                border = "rounded",
              })
            end,
          })
        end,
        desc = "Show Output (Neotest)",
      },
    },
    ---@module 'neotest'
    ---@class (partial) neotest.Config
    opts = {
      -- Can be a list of adapters like what neotest expects,
      -- or a list of adapter names,
      -- or a table of adapter names, mapped to adapter configs.
      -- The adapter will then be automatically loaded with the config.
      adapters = {
        "neotest-jest",
      },
      -- Example for loading neotest-golang with a custom config
      -- adapters = {
      --   ["neotest-golang"] = {
      --     go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
      --     dap_go_enabled = true,
      --   },
      -- },
      output = {
        enabled = true,
        open_on_run = false,
      },
      quickfix = {
        enabled = true,
        open = false,
      },
      status = {
        enabled = true,
        signs = true,
        virtual_text = false,
      },
    },
  },
}
