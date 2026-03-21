local M = {}

--- Import an astrocommunity plugin and replace all keymaps registered under a given prefix.
---
--- Usage:
---   local unmap = require("lib.keymaps")
---   return {
---     "AstroNvim/astrocommunity",
---     keymaps.unmap("astrocommunity.git.neogit", "<Leader>gn", {
---       { "n", "<Leader>gg", "<Cmd>Neogit<CR>", desc = "Open Neogit" },
---     }),
---   }
---
---@param import_path string  e.g. "astrocommunity.git.neogit"
---@param prefix      string  the keymap prefix the plugin registers under, e.g. "<Leader>gn"
---@param mappings    table   list of { mode, key, cmd, ...opts } tables
---@return table  lazy.nvim spec list
function M.unmap(import_path, prefix, mappings)
  return {
    { import = import_path },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        for _, mode_maps in pairs(opts.mappings) do
          for key in pairs(mode_maps) do
            if key:find(prefix, 1, true) == 1 then mode_maps[key] = nil end
          end
        end
        for _, m in ipairs(mappings) do
          local mode, key, cmd = m[1], m[2], m[3]
          local extra = {}
          for k, v in pairs(m) do
            if type(k) ~= "number" then extra[k] = v end
          end
          opts.mappings[mode] = opts.mappings[mode] or {}
          opts.mappings[mode][key] = vim.tbl_extend("force", { cmd }, extra)
        end
      end,
    },
  }
end

--- Import an astrocommunity plugin and rename all keymaps under old_prefix to new_prefix,
--- preserving their values across all modes.
---
--- Usage:
---   local unmap = require("lib.keymaps")
---   return {
---     "AstroNvim/astrocommunity",
---     keymaps.reprefix("astrocommunity.ai.sidekick-nvim", "<Leader>A", "<Leader>a"),
---   }
---
---@param import_path string  e.g. "astrocommunity.ai.sidekick-nvim"
---@param old_prefix  string  the prefix to replace, e.g. "<Leader>A"
---@param new_prefix  string  the replacement prefix, e.g. "<Leader>a"
---@return table  lazy.nvim spec list
function M.reprefix(import_path, old_prefix, new_prefix)
  return {
    { import = import_path },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        for _, mode_maps in pairs(opts.mappings) do
          local to_move = {}
          for key, val in pairs(mode_maps) do
            if key:find(old_prefix, 1, true) == 1 then
              to_move[key] = val
            end
          end
          for old_key, val in pairs(to_move) do
            mode_maps[old_key] = nil
            mode_maps[new_prefix .. old_key:sub(#old_prefix + 1)] = val
          end
        end
      end,
    },
  }
end

return M
