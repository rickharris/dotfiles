---@type LazySpec
return {
  "lewis6991/gitsigns.nvim",
  enabled = vim.fn.executable("git") == 1,
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
  opts = {
    gh = true,
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      -- Navigation
      map("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gitsigns.nav_hunk("next")
        end
      end, "Next Git Hunk")

      map("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gitsigns.nav_hunk("prev")
        end
      end, "Previous Git Hunk")

      map("n", "]C", function()
        gitsigns.nav_hunk("last")
      end, "Last Git Hunk")

      map("n", "[C", function()
        gitsigns.nav_hunk("first")
      end, "First Git Hunk")

      -- Actions
      map("n", "<leader>gs", gitsigns.stage_hunk, "Stage hunk")
      map("n", "<leader>gr", gitsigns.reset_hunk, "Reset hunk")

      map("v", "<leader>gs", function()
        gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage hunk")

      map("v", "<leader>gr", function()
        gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset hunk")

      map("n", "<leader>gS", gitsigns.stage_buffer, "Stage buffer")
      map("n", "<leader>gR", gitsigns.reset_buffer, "Reset buffer")

      -- Text object
      map({ "o", "x" }, "ih", gitsigns.select_hunk)
    end,
  },
}
