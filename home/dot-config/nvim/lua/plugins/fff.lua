return {
  "dmtrKovalenko/fff.nvim",
  build = function()
    -- this will download prebuild binary or try to use existing rustup toolchain to build from source
    -- (if you are using lazy you can use gb for rebuilding a plugin if needed)
    require("fff.download").download_or_build_binary()
  end,
  opts = {
    prompt = " ",
  },
  {
    "madmaxieee/fff-snacks.nvim",
    dependencies = {
      "dmtrKovalenko/fff.nvim",
      "folke/snacks.nvim",
    },
    cmd = "FFFSnacks",
    keys = {
      {
        "<leader><leader>",
        "<cmd>FFFSnacks<cr>",
        desc = "FFFind files",
      },
    },
    config = true,
  },
}
