local M = {}

-- Default statusline icon (nf-oct-git_pull_request). Override via setup({ icon }).
local DEFAULT_ICON = ""

---@type table|nil  resolved options (set by setup)
M.opts = nil

local state = {
  count = nil, ---@type integer|nil
  timer = nil, ---@type uv.uv_timer_t?
  last_refresh = 0, ---@type number  -- ms (vim.uv.now)
}

local function defaults()
  return {
    reviewer = "@me",
    state = "open",
    limit = 100,
    icon = DEFAULT_ICON,
    refresh = {
      interval_ms = 5 * 60 * 1000,
      on_focus = true,
      focus_throttle_ms = 60 * 1000,
    },
  }
end

-- Cached count (nil until the first fetch resolves).
function M.count()
  return state.count
end

-- Statusline string: always the icon; the count when known, else "…" while the
-- first fetch is pending. Safe to call before setup().
function M.statusline()
  local icon = (M.opts and M.opts.icon) or DEFAULT_ICON
  local count = state.count
  return icon .. " " .. (count == nil and "…" or tostring(count))
end

-- Trigger an async refresh of the cached count.
function M.refresh()
  state.last_refresh = vim.uv.now()
  require("pr_reviews.gh").fetch_count(M.opts or defaults(), function(count)
    state.count = count
    pcall(function()
      require("lualine").refresh()
    end)
  end)
end

-- Open the picker.
function M.pick(opts)
  return require("pr_reviews.picker").open(opts)
end

-- Register an "Open in Octo" action into Snacks' gh action set so it appears in
-- the gh_pr <cr> actions menu for PRs, and bump priorities so the menu leads
-- with: Open in Browser, Open in Octo, Start a review. Idempotent.
--
-- Note: priorities live on the shared snacks.gh actions, so this also reorders
-- the built-in gh_pr menu — desirable, and the only place priority is read.
local function register_octo_action()
  local ok, actions = pcall(require, "snacks.gh.actions")
  if not ok then
    return
  end

  actions.actions.octo_review = {
    desc = "Open in Octo",
    type = "pr",
    icon = " ",
    priority = 1002,
    action = function(item, ctx)
      local uri =
        require("octo.utils").get_pull_request_uri(item.number, item.repo)
      -- Close the picker first; a bare :edit would open octo in the picker's
      -- floating prompt window. Defer the edit until focus returns to the editor.
      if ctx and ctx.picker then
        ctx.picker:close()
      end
      vim.schedule(function()
        vim.cmd("edit " .. uri)
      end)
    end,
  }

  if actions.actions.gh_browse then
    actions.actions.gh_browse.priority = 1003
  end
  if actions.actions.gh_start_review then
    actions.actions.gh_start_review.priority = 1001
  end
end

local function start_timer()
  if state.timer then
    return
  end
  local timer = vim.uv.new_timer()
  if not timer then
    return
  end
  state.timer = timer
  timer:start(0, M.opts.refresh.interval_ms, function()
    vim.schedule(M.refresh)
  end)
end

local function setup_focus_autocmd()
  if not M.opts.refresh.on_focus then
    return
  end
  vim.api.nvim_create_autocmd("FocusGained", {
    group = vim.api.nvim_create_augroup("PrReviewsFocus", { clear = true }),
    callback = function()
      if
        vim.uv.now() - state.last_refresh >= M.opts.refresh.focus_throttle_ms
      then
        M.refresh()
      end
    end,
  })
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", defaults(), opts or {})
  register_octo_action()
  start_timer()
  setup_focus_autocmd()
end

return M
