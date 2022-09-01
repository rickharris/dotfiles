vim.g.mapleader = " "
vim.o.termguicolors = true
vim.o.number = true -- line numbers
vim.o.autoread = true -- reload changed files automatically
vim.o.hidden = true -- switch between buffers without saving
vim.o.laststatus = 2 -- show status bar
vim.o.foldenable = false -- don't fold my code, either
vim.o.wrap = false -- no wrapping please, thank you
vim.o.scrolloff = 8 -- start scrolling when cursor is 8 rows away from edge
vim.o.sidescrolloff = 8 -- start scrolling when cursor is 8 columns away from edge
vim.o.incsearch = true -- Find the next match as we type the search
vim.o.hlsearch = true -- Hilight searches by default
vim.o.ignorecase = true -- Ignore case for searches...
vim.o.smartcase = true --  ... unless you use a capital letter in search
vim.o.autoindent = true -- match indentation on newlines
vim.o.smartindent = true -- attempt to be smart about indenting/un-indenting newlines
vim.o.smarttab = true -- treat a series of spaces as tabs when appropriate
vim.o.shiftwidth = 2 -- two-space indention width
vim.o.softtabstop = 2
vim.o.tabstop = 2
vim.o.expandtab = true -- use spaces instead of tabs
vim.o.colorcolumn = 81
vim.o.undofile = true
vim.o.undodir = "~/.vim/undo"

require("plugins")
require("keymaps")

vim.cmd([[colorscheme tokyonight]])
