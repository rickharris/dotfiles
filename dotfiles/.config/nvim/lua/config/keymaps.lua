-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

if vim.g.vscode then
    vim.keymap.set("n", "]d", [[<cmd>lua require('vscode').action('editor.action.marker.next')<cr>]])
    vim.keymap.set("n", "[d", [[<cmd>lua require('vscode').action('editor.action.marker.prev')<cr>]])
end