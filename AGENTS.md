# Guidance for coding agents

Personal dotfiles for macOS on Apple silicon. `home/dot-local/bin/dot` (bash)
bootstraps a machine and links everything with GNU Stow. The README covers the
commands and how layers work; this file covers what is easy to get wrong.

## This checkout is live

`~/.zshrc`, `~/.config/nvim`, `~/.claude/settings.json` and the rest are
symlinks into this working tree, and `~/.local/bin/dot` is the script in it. An
edit here takes effect on the machine immediately, and a broken `dot` or
`.zshrc` is broken for real.

- **Do not run `dot`, `dot install`, `dot link`, `dot unlink`, `dot prefs` or
  `dot update` to test a change.** They act on the real home directory. Run
  the tests instead, or point all three overrides and the cache directory at
  a temp directory:

  ```sh
  t=$(mktemp -d) && mkdir -p "$t/base/home" "$t/target"
  DOTFILES=$t/base DOT_TARGET=$t/target DOT_LAYERS_FILE=$t/layers \
    XDG_CACHE_HOME=$t/cache /bin/bash home/dot-local/bin/dot link
  ```

- `dot doctor` is always safe. It changes nothing in the home directory, but
  it does fetch from `origin`.
- `dot update --check` fetches from `origin` and writes one cache file, so it
  is safe too.
- Run the others against the real home only when the task is to apply a
  change to this machine, and say that you did.

## Checks

```sh
mise run check   # lint, tests and Lua diagnostics
mise run lint    # formatting and ShellCheck, changing nothing
mise run fmt     # format every file a formatter covers
mise run test    # syntax and tests only
mise run lua     # what lua-language-server reports
mise run tools   # install the global mise tools into a temp directory
```

CI runs `check` and `tools`. `tools` is not part of `check` because it
downloads about 1.5 GB. Run it after changing a tool or a version in
`home/dot-config/mise/config.toml`: mise refuses npm packages that fail its
supply-chain checks, but only when it installs one, so nothing else notices.
If it refuses one, find out why before adding an exemption, and exempt the
narrowest thing that works.

The tools are pinned in `mise.toml`: `oxfmt` for Markdown, JSON, YAML and
TOML, `stylua` for Lua, `shfmt` and `shellcheck` for shell, and `rumdl` to
lint Markdown. Run them through mise (`mise exec -- oxfmt ...`), not from
wherever else they are installed, because their output changes between
versions. On a new checkout run `mise trust && mise install` once.

Files that apps rewrite themselves are listed under `ignorePatterns` in
`.oxfmtrc.json`. Add a file there instead of fighting the app over its
formatting.

The tests run `dot` against temp fixtures, and refuse to start without `stow`.

`mise run lua` runs `tests/lua_check.sh`, which reports the diagnostics
`lua-language-server` finds in the Neovim config: the ones the editor shows. It
reads the plugins' type annotations, so it needs the plugins Neovim has
installed, and takes about fifteen seconds. `.luarc.json` tells the server
where they are. After you edit Lua, a hook runs the check when you stop and
hands back what it finds. Fix a diagnostic where it is reported; do not turn
the rule off.

`install` and `prefs` have no tests, because they install software and change
system settings. Nor does the last step of `update`, which hands over to
`install`; the tests run the pull through the hidden `dot __pull`. After
changing any of them, re-read the step order and say plainly that it was not
exercised.

## Layout

| Path                               | What it is                                                                                                                                                                                              |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `home/`                            | Linked into `~` file by file. `dot-foo` becomes `.foo`.                                                                                                                                                 |
| `layers/personal/`                 | A layer for personal machines only: its own `Brewfile`, plus a `folded/` package linked directory by directory (Karabiner).                                                                             |
| `Brewfile`                         | Installed on every machine. Personal-only apps go in `layers/personal/Brewfile`.                                                                                                                        |
| `home/dot-config/nvim/`            | The Neovim config (`vim.pack`). `nvim-shared/` holds Lua shared with it.                                                                                                                                |
| `home/dot-config/mise/config.toml` | The **global** mise config: default versions of node, Neovim and every language server, formatter and linter Neovim uses. Neovim runs them through mise shims, so a project `mise.toml` overrides them. |
| `home/dot-claude/settings.json`    | The user's **global** Claude Code settings, live.                                                                                                                                                       |
| `.claude/settings.json`            | Settings for agents working **in this repo**. Not linked anywhere.                                                                                                                                      |

Use a `folded/` package for an app that saves config by replacing the file,
which would otherwise turn a file-level link into a regular file.

## Rules

- **This repo is public.** Nothing work-related goes in it: no hostnames,
  paths, repo URLs or names of internal tools. Work config lives in a separate
  layer that this repo never mentions.
- **Do not start a name under `home/` or `folded/` with `dot-`** unless it
  should become a dotfile. Stow renames every file and directory that starts
  with `dot-`, at any depth, so `dot-prompt.zsh` is linked as `.prompt.zsh`.
- **Stage files by name.** Never `git add -A` or `git add home`. Apps write to
  their config through the symlinks, so the tree often holds edits the user has
  not decided to commit; `home/dot-claude/settings.json` is the usual one.
- **Look up current versions** of GitHub Actions and tools before pinning
  them. Do not write a version from memory.
- **`dot` must run on bash 3.2**, the bash macOS ships, because it bootstraps
  a machine before anything newer is installed. No associative arrays, no
  `mapfile`, no `${var,,}`. ShellCheck does not catch this; running the tests
  with `/bin/bash` does, which `mise run test` and the hook both do.
- **`.zshrc` and the completion file stay zsh.** ShellCheck refuses zsh, and
  `shfmt`'s zsh support is incomplete: if it cannot parse a construct, write
  that construct another way.
- Under `set -e`, end a function with `if`, not `[[ ... ]] && cmd`, so a false
  test is not its exit status.
- Error messages from `dot` start with `dot:` and a space, and go to stderr.

## Git

- Commit subjects are `area: lowercase summary`, for example
  `dot: prune dangling links` or `nvim: update plugins`.
- Dependent pull requests are stacked with `gh stack`.
