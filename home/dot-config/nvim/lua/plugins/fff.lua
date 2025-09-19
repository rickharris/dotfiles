return {
  "dmtrKovalenko/fff.nvim",
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
