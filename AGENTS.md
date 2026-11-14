# Guidance for coding agents

Personal dotfiles for macOS on Apple silicon. `home/dot-local/bin/dot` (zsh)
bootstraps a machine and links everything with GNU Stow. The README covers the
commands and how layers work; this file covers what is easy to get wrong.

## This checkout is live

`~/.zshrc`, `~/.config/nvim`, `~/.claude/settings.json` and the rest are
symlinks into this working tree, and `~/.local/bin/dot` is the script in it. An
edit here takes effect on the machine immediately, and a broken `dot` or
`.zshrc` is broken for real.

- **Do not run `dot`, `dot install`, `dot link`, `dot unlink` or `dot prefs`
  to test a change.** They act on the real home directory. Run the tests
  instead, or point all three overrides at a temp directory:

  ```sh
  t=$(mktemp -d) && mkdir -p "$t/base/home" "$t/target"
  DOTFILES=$t/base DOT_TARGET=$t/target DOT_LAYERS_FILE=$t/layers \
    zsh home/dot-local/bin/dot link
  ```

- `dot doctor` is read-only and always safe.
- Run those four against the real home only when the task is to apply a
  change to this machine, and say that you did.

## Checks

```sh
mise run check   # everything CI runs: formatting, syntax, tests
mise run fmt     # format every file a formatter covers
mise run test    # syntax and tests only
```

The formatters are pinned in `mise.toml`: `prettier` for Markdown, JSON and
YAML, `stylua` for Lua, `taplo` for TOML and `shfmt` for shell. Run them
through mise (`mise exec -- prettier ...`), not from wherever else they are
installed, because their output changes between versions. On a new checkout
run `mise trust && mise install` once.

Files that apps rewrite themselves are listed in `.prettierignore`. Add a file
there instead of fighting the app over its formatting.

The tests run `dot` against temp fixtures, and refuse to start without `stow`.

`install` and `prefs` have no tests, because they install software and change
system settings. After changing them, re-read the step order and say plainly
that it was not exercised.

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
- **Stage files by name.** Never `git add -A` or `git add home`. Apps write to
  their config through the symlinks, so the tree often holds edits the user has
  not decided to commit; `home/dot-claude/settings.json` is the usual one.
- **Look up current versions** of GitHub Actions and tools before pinning
  them. Do not write a version from memory.
- **`dot` is zsh, not bash.** `shellcheck` refuses zsh scripts, so it cannot
  lint it. `shfmt` formats it, but its zsh support is incomplete: if it cannot
  parse a construct, write that construct another way.
- Under `set -e`, end a function with `if`, not `[[ ... ]] && cmd`, so a false
  test is not its exit status.
- Error messages from `dot` start with `dot: ` and go to stderr.

## Git

- Commit subjects are `area: lowercase summary`, for example
  `dot: prune dangling links` or `nvim: update plugins`.
- Dependent pull requests are stacked with `gh stack`.
