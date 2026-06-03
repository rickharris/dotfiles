-- Zero-dependency test for pr_reviews.query. Run with: nvim -l <this file>
local here = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
package.path = here .. "../lua/?.lua;" .. here .. "../lua/?/init.lua;" .. package.path

local query = require("pr_reviews.query")

local failures = 0
local function check(name, ok)
  if ok then
    print("ok   - " .. name)
  else
    failures = failures + 1
    print("FAIL - " .. name)
  end
end
local function eq(a, b)
  return vim.deep_equal(a, b)
end

-- build_search_args: defaults
check(
  "build_search_args default",
  eq(query.build_search_args({}), {
    "search",
    "prs",
    "draft:false",
    "--review-requested",
    "@me",
    "--state",
    "open",
    "--limit",
    "100",
  })
)

-- build_search_args: overrides
check(
  "build_search_args overrides",
  eq(query.build_search_args({ reviewer = "octocat", state = "open", limit = 25 }), {
    "search",
    "prs",
    "draft:false",
    "--review-requested",
    "octocat",
    "--state",
    "open",
    "--limit",
    "25",
  })
)

-- build_search_args: free-text search term inserted before qualifiers
check(
  "build_search_args with search term",
  eq(query.build_search_args({}, "fix bug"), {
    "search",
    "prs",
    "fix bug",
    "draft:false",
    "--review-requested",
    "@me",
    "--state",
    "open",
    "--limit",
    "100",
  })
)

-- empty search term is ignored
check("build_search_args ignores empty search", eq(query.build_search_args({}, ""), query.build_search_args({})))

-- every requested field is one gh search prs actually supports
local supported = {}
for _, f in ipairs(query.supported_fields) do
  supported[f] = true
end
local all_supported = true
for _, f in ipairs(query.fields) do
  if not supported[f] then
    all_supported = false
    print("  unsupported field: " .. f)
  end
end
check("all requested fields are supported by gh search prs", all_supported)
check("count_fields is non-empty (--json requires a field)", #query.count_fields > 0)

if failures > 0 then
  error(failures .. " test(s) failed")
end
print("\nall query tests passed")
