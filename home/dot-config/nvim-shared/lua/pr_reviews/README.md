# pr_reviews

Surfaces the pull requests **personally awaiting your review** inside Neovim:

- a **lualine** component showing an icon + the count of open, non-draft PRs
  where you are individually requested as a reviewer, and
- a **Snacks picker** listing those PRs across all repos, with actions to open
  them in the browser, in [octo.nvim](https://github.com/pwntester/octo.nvim),
  or via Snacks' own review flow.

The query is `gh search prs --review-requested=@me --state=open` with a
server-side `draft:false` filter — so it matches PRs requested of _you_, not of
a team you belong to.

This is a small local module shared between Neovim configs (it lives under
`~/.config/nvim-shared`), not a published plugin.

## Requirements

- Neovim with [`snacks.nvim`](https://github.com/folke/snacks.nvim) (picker enabled).
- The [`gh`](https://cli.github.com) CLI, authenticated (`gh auth login`).
- Optional: `octo.nvim` (for the "Open in Octo" action) and `lualine.nvim`
  (for the statusline component). The module degrades gracefully if either is
  absent.

## How it works

The picker **clones Snacks' built-in `gh_pr` source**, overriding only the
finder. `gh_pr`'s finder runs `gh pr list`, which is scoped to the current repo;
this module instead runs `gh search prs` (cross-repo) through
`snacks.gh.api.fetch` — so Snacks still owns `--json` handling, JSON decoding,
formatting, preview, and the native PR actions. Results are wrapped as
`snacks.gh` items, so they behave exactly like `gh_pr` items.

The statusline count is fetched asynchronously on a timer and cached; the
component reads the cached value and never blocks.

## Setup

The module must be on the runtimepath, then `setup()` called once.

```lua
require("pr_reviews").setup({
  -- defaults shown
  reviewer = "@me",   -- gh --review-requested value
  state = "open",     -- gh --state value
  limit = 100,        -- max PRs fetched
  -- icon = "…",     -- statusline icon; defaults to nf-oct-git_pull_request (U+F4AF)
  refresh = {
    interval_ms = 5 * 60 * 1000, -- poll every 5 minutes
    on_focus = true,             -- also refresh on FocusGained
    focus_throttle_ms = 60 * 1000, -- ...at most once per minute
  },
})
```

### vim.pack / single-file config

```lua
vim.opt.runtimepath:append(vim.fn.expand("~/.config/nvim-shared"))
require("pr_reviews").setup({})
```

### lazy.nvim

```lua
{
  dir = vim.fn.expand("~/.config/nvim-shared"),
  name = "pr-reviews",
  init = function()
    -- ensure the dir is on the runtimepath at startup, regardless of load order
    vim.opt.runtimepath:append(vim.fn.expand("~/.config/nvim-shared"))
  end,
  config = function()
    require("pr_reviews").setup({})
  end,
}
```

## Statusline (lualine)

Add the component to any section. It always renders the icon, showing the count
once known or `…` while the first fetch is pending:

```lua
sections = {
  lualine_x = {
    { function() return require("pr_reviews").statusline() end },
    "diff",
    "filetype",
  },
}
```

## Picker

```lua
vim.keymap.set("n", "<leader>or", function()
  require("pr_reviews").pick()
end, { desc = "Review requests" })
```

The picker opens immediately with a loading state. It inherits `gh_pr`'s live
mode, so typing searches the review-requested set server-side via `gh`.

Press `<cr>` on a PR to open the actions menu. The module orders it as:

1. **Open in Browser**
2. **Open in Octo** — opens the PR as `octo://owner/repo/pull/N`
3. **Start a review** (Snacks' native review)
4. …the rest of Snacks' native PR actions (diff, comment, approve, …)

> Note: the action priorities are set on the shared `snacks.gh` actions, so the
> built-in `gh_pr` menu is reordered the same way.

## API

| Function       | Description                                                                                   |
| -------------- | --------------------------------------------------------------------------------------------- |
| `setup(opts)`  | Resolve options, register the octo action, start the refresh timer and `FocusGained` autocmd. |
| `count()`      | Cached count (`integer`), or `nil` until the first fetch resolves.                            |
| `statusline()` | Statusline string (`icon .. " " .. count`). Safe to call before `setup()`.                    |
| `refresh()`    | Trigger an async refresh of the cached count.                                                 |
| `pick(opts?)`  | Open the picker. `opts` are merged over the defaults.                                         |

## Files

| File                         | Responsibility                                                               |
| ---------------------------- | ---------------------------------------------------------------------------- |
| `query.lua`                  | Pure helpers: requested fields and `gh search prs` argv. Unit-tested.        |
| `gh.lua`                     | Async count fetch via `snacks.gh.api`.                                       |
| `picker.lua`                 | Snacks finder + `open()` (clones `gh_pr`).                                   |
| `init.lua`                   | `setup`, state, count cache, statusline, refresh timer/autocmd, octo action. |
| `../../tests/query_spec.lua` | Tests for `query.lua` (run with `nvim -l`).                                  |

## Notes

- The picker reuses **undocumented** `snacks.gh` internals (`api`, `item`,
  `actions`, the `gh_pr` source). Snacks updates may require adjustments.
- Auth/error handling is quiet (`notify = false`): if `gh` fails, the count
  simply stays at `…` and recovers on the next refresh.
