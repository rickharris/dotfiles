vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.number = true
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.pack.add({
  "https://github.com/esmuellert/codediff.nvim",
  "https://github.com/folke/lazydev.nvim",
  "https://github.com/folke/snacks.nvim",
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/NeogitOrg/neogit",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/nvim-mini/mini.icons",
})

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "oxfmt", "oxlint", "stylua" },
})
require("mini.icons").setup()
require("tokyonight").setup({ style = "moon" })
require("which-key").setup()

vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  },
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({
        bufnr = bufnr,
        scope = "cursor",
        focus = false,
      })
    end,
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  once = true,
  callback = function()
    require("lazydev").setup({
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    })
  end,
})

vim.lsp.config("lua_ls", {
  ---@module 'lspconfig'
  ---@type lspconfig.settings.lua_ls
  settings = {
    Lua = {
      format = { enable = false },
    },
  },
})

local oxlint_base_on_attach = vim.lsp.config.oxlint.on_attach
vim.lsp.config("oxlint", {
  on_attach = function(client, bufnr)
    if not oxlint_base_on_attach then
      return
    end

    oxlint_base_on_attach(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "LspOxlintFixAll",
    })
  end,
})

vim.cmd.colorscheme("tokyonight")
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    vim.lsp.buf.format()
  end,
})

require("which-key").add({
  {
    "<leader><space>",
    function()
      require("snacks").picker.smart()
    end,
    desc = "find files",
  },
  { "<leader>b", group = "buffer" },
  { "<leader>bd", "<cmd>bdelete", mode = "n", desc = "delete buffer" },
  { "<leader>g", group = "git" },
  { "<leader>gg", "<cmd>Neogit<cr>", desc = "neogit" },
})
