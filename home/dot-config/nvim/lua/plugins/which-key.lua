return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>b", group = "Buffers" },
      { "<leader>g", group = "Git" },
      { "<leader>t", group = "Test" },
      { "<leader>L", "<cmd>Lazy<cr>" },
    },
  },
}
