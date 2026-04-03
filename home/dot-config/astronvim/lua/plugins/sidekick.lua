---@type LazySpec
-- The sidekick community plugin registers all keybindings under <Leader>A.
-- This overrides astrocore's mappings to move them to <Leader>a instead.
return {
  "AstroNvim/astrocore",
  ---@param opts AstroCoreOpts
  opts = function(_, opts)
    local maps = assert(opts.mappings)
    for mode, bindings in pairs(maps) do
      for key, val in pairs(bindings) do
        if key:sub(1, 9) == "<Leader>A" then
          maps[mode]["<Leader>a" .. key:sub(10)] = val
          maps[mode][key] = false
        end
      end
    end
  end,
}
