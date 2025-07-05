-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Only use prettier in projects that use it.
vim.g.lazyvim_prettier_needs_config = true

--- Default value:
--- vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }
--- `lsp` is not great for monorepos, lua feels unnecessarily restrictive.
vim.g.root_spec = { ".git", "cwd" }
