-- Snacks picker for PRs awaiting review. Clones the built-in `gh_pr` source,
-- overriding only the finder so the list comes from a cross-repo
-- `gh search prs` instead of the repo-scoped `gh pr list`.
local query = require("pr_reviews.query")

local M = {}

-- Resolve the query opts from the configured module options (set in setup()).
local function search_opts()
  local ok, root = pcall(require, "pr_reviews")
  return (ok and root.opts) or query.defaults
end

-- Snacks finder: run the cross-repo search and yield Snacks gh items. Inherits
-- gh_pr's live mode, so the picker opens immediately with a loading state and
-- the typed text is passed to `gh` as a server-side search term.
---@type snacks.picker.finder
function M.finder(_, ctx)
  local api = require("snacks.gh.api")
  local Item = require("snacks.gh.item")
  local search = ctx and ctx.filter and ctx.filter.search or nil
  local args = query.build_search_args(search_opts(), search)
  return function(cb)
    local data =
      api.fetch_sync({ args = args, fields = query.fields, notify = false })
    for _, raw in ipairs(data or {}) do
      -- Item:update derives item.repo from item.url automatically.
      ---@diagnostic disable-next-line: missing-fields
      cb(Item.new(raw, { type = "pr", fields = query.fields }))
    end
  end
end

-- Open the picker. Clones gh_pr (inheriting live mode + format/preview/actions);
-- we only swap the finder and keep the preview unfolded (gh_pr's preview sets
-- foldmethod=expr but no foldlevel, which collapses on a reused preview window).
---@param opts table|nil  extra picker opts merged over the defaults
function M.open(opts)
  return Snacks.picker.pick(
    "gh_pr",
    vim.tbl_deep_extend("force", {
      finder = M.finder,
      title = "  PR Reviews Requested",
      win = { preview = { wo = { foldenable = false, foldlevel = 99 } } },
    }, opts or {})
  )
end

return M
