-- Async GitHub access, layered on Snacks' own gh API so Snacks owns spawning,
-- --json injection, and JSON decoding.
local query = require("pr_reviews.query")

local M = {}

-- Fetch just the count of open, non-draft PRs awaiting the user's review.
-- Calls `cb(count)` on the main loop; count is nil if gh failed/returned nothing.
---@param opts table|nil
---@param cb fun(count: integer|nil)
function M.fetch_count(opts, cb)
  local api = require("snacks.gh.api")
  api.fetch(function(_, data)
    local count = data and #data or nil
    vim.schedule(function()
      cb(count)
    end)
  end, {
    args = query.build_search_args(opts),
    fields = query.count_fields,
    notify = false,
  })
end

return M
