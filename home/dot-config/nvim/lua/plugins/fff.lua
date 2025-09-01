return {
  "dmtrKovalenko/fff.nvim",
  build = "cargo build --release",
  opts = {
    prompt = " ",
  },
  keys = {
    {
      "<leader><leader>",
      function()
        require("fff").find_files()
      end,
      desc = "FFFind files",
    },
  },
}
