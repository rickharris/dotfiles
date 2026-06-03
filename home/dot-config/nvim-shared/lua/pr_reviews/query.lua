-- Pure helpers for the pr_reviews module. No `vim`/snacks dependencies so this
-- file is unit-testable in isolation.
local M = {}

-- Fields requested from `gh search prs`. The full set of search-supported
-- fields useful for list rendering. Snacks' formatter reads a subset
-- (state/number/title/author/labels/url); preview detail is fetched per-item by
-- Snacks via `gh pr view`.
M.fields = {
  "number",
  "title",
  "author",
  "labels",
  "state",
  "isDraft",
  "url",
  "repository",
  "createdAt",
  "updatedAt",
  "closedAt",
  "commentsCount",
  "id",
  "body",
}

-- Minimal field set for the statusline count (--json requires >= 1 field).
M.count_fields = { "url" }

-- Fields `gh search prs --json` actually supports (gh 2.88). Used by the test
-- to guard against requesting a field that would make gh error.
M.supported_fields = {
  "assignees",
  "author",
  "authorAssociation",
  "body",
  "closedAt",
  "commentsCount",
  "createdAt",
  "id",
  "isDraft",
  "isLocked",
  "isPullRequest",
  "labels",
  "number",
  "repository",
  "state",
  "title",
  "updatedAt",
  "url",
}

M.defaults = {
  reviewer = "@me",
  state = "open",
  limit = 100,
}

-- Build the argv for `gh search prs` (subcommand + qualifiers + flags). The
-- `--json`/`--repo` flags are added by snacks.gh.api.fetch, not here. An
-- optional free-text `search` term (e.g. the picker's live input) is added as a
-- leading query qualifier so `gh` filters server-side, matching `gh_pr`.
---@param opts table|nil
---@param search string|nil
---@return string[]
function M.build_search_args(opts, search)
  opts = opts or {}
  local reviewer = opts.reviewer or M.defaults.reviewer
  local state = opts.state or M.defaults.state
  local limit = opts.limit or M.defaults.limit
  local args = { "search", "prs" }
  if search and search ~= "" then
    args[#args + 1] = search
  end
  args[#args + 1] = "draft:false"
  args[#args + 1] = "--review-requested"
  args[#args + 1] = reviewer
  args[#args + 1] = "--state"
  args[#args + 1] = state
  args[#args + 1] = "--limit"
  args[#args + 1] = tostring(limit)
  return args
end

return M
