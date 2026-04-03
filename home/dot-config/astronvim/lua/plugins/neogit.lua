---@type LazySpec
-- The neogit community plugin registers keybindings under <Leader>gn.
-- This clears all of them and maps only the tab page open to <Leader>gg.
return {
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = assert(opts.mappings)
      -- Reuse the community plugin's <Leader>gnt binding for <Leader>gg,
      -- then clear all <Leader>gn bindings
      maps.n["<Leader>gg"] = maps.n["<Leader>gnt"]
      for mode, bindings in pairs(maps) do
        for key in pairs(bindings) do
          if key:sub(1, 10) == "<Leader>gn" then maps[mode][key] = false end
        end
      end
    end,
  },
  {
    "NeogitOrg/neogit",
    optional = true,
    ---@module 'neogit'
    ---@type NeogitConfig
    opts = {
      signs = {
        hunk = { "", "" },
        item = { "", "" },
        section = { "", "" },
      },
    },
  },
}
