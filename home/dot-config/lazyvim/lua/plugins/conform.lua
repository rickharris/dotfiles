local fileTypesToAdd = {
  oxlint = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
}

---@module 'lazy'
---@type LazySpec
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for formatter, supported in pairs(fileTypesToAdd) do
        for _, ft in ipairs(supported) do
          opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
          table.insert(opts.formatters_by_ft[ft], formatter)
        end
      end
    end,
  },
}
