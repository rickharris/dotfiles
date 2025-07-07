---@type LazySpec
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  ---@module 'noice'
  ---@type NoiceConfig
  opts = {
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
    },
    -- you can enable a preset for easier configuration
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    "folke/snacks.nvim",
  },
  specs = {
    {
      "blink.cmp",
      optional = true,
      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        -- Use Noice's command palette for command line completions
        cmdline = { enabled = false },
      },
    },
    {
      "nvim-treesitter/nvim-treesitter",
      optional = true,
      opts = {
        ensure_installed = {
          "bash",
          "lua",
          "markdown",
          "markdown_inline",
          "regex",
          "vim",
        },
      },
    },
  },
}
