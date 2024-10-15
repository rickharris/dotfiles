return {
  { "RRethy/base16-nvim" },
  { "projekt0n/github-nvim-theme", name = "github-theme" },
  { "EdenEast/nightfox.nvim" },
  { "calind/selenized.nvim" },
  {
    "cormacrelf/dark-notify",
    lazy = false,
    priority = 1000,
    config = function()
      require("dark_notify").run({
        schemes = {
          dark = {
            bg = "dark",
            colorscheme = "tokyonight-moon",
          },
          light = {
            bg = "light",
            colorscheme = "dawnfox",
          },
        },
      })
    end,
  },
}
