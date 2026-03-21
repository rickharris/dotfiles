vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.autowrite = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.laststatus = 3
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.showmode = false
vim.opt.smartcase = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.tabstop = 2
vim.opt.undofile = true
vim.opt.undolevels = 10000

-- Make copying and pasting from clipboard a little easier
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p')
vim.keymap.set({ "n", "v" }, "<leader>P", '"+P')

vim.filetype.add({
  pattern = {
    [".*/ghostty/config"] = "conf",
  },
  filename = {
    ["Brewfile"] = "ruby",
    ["dot-gitconfig"] = "gitconfig",
    ["dot-zshrc"] = "zsh",
  },
})
