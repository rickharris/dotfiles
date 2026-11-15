# Dotfiles

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/rickharris/dotfiles/refs/heads/main/home/dot-local/bin/dot)
```

## Commands

| Command              | What it does                              |
| -------------------- | ----------------------------------------- |
| `dot`                | Run `install` and then `prefs`            |
| `dot install`        | Install dependencies                      |
| `dot link`           | Link dotfiles to the correct location     |
| `dot unlink`         | Remove dotfile symlinks                   |
| `dot doctor`         | Check for drift without changing anything |
| `dot prefs`          | Set system and app preferences            |
| `dot update`         | Pull the latest dotfiles and run install  |
| `dot update --check` | Report how far behind `origin/main` it is |

## Keeping up to date

The prompt shows `dot ⇣3` when this checkout is three commits behind
`origin/main`. It reads a count that `dot update --check` records, and runs
that check in the background when the count is more than an hour old, or when
the checkout has moved since (a `git pull`, a commit, a switch of branch). The
new count shows on the prompt after the check finishes. `dot doctor` reports
the same thing, and fetches to find out.

`dot update` pulls this repo and every layer that is a git repo of its own,
then runs `dot install`. It does not run `dot prefs`. It only fast-forwards,
so local edits are left alone, and it refuses when this repo is not on `main`.

`dot install` also moves the Neovim plugins to the revisions in
`nvim-pack-lock.json`, so a plugin update that was pulled takes effect.
Neovim on its own only does that for plugins that are not installed yet.

## Layers

`dot` links and installs from a list of layers. This repo is always the first
one. Any others are listed in `~/.config/dot/layers`, a file that is not
tracked anywhere, so each machine decides for itself which layers it uses.

The layers file holds one directory per line. Blank lines and lines starting
with `#` are ignored, and a leading `~` expands to the home directory. Paths
must be absolute.

Every layer has the same layout, and every part is optional:

- `home/` is linked into the home directory file by file.
- `folded/` is linked directory by directory. Use it for apps that save their
  config by replacing the file, which would otherwise break a file-level
  link.
- `Brewfile` is installed by `dot install`.

### The personal layer

`layers/personal` in this repo holds apps and config that only belong on
personal machines. The first time `dot install` runs on a machine it asks
whether to enable it, and records the answer by writing the layers file. To
change the answer later, edit that file.

### Machines set up before layers existed

Such a machine has no layers file, so it has never been asked about the
personal layer, and `dot link` says so. Run `dot install` to be asked, or
create the layers file by hand.

The Karabiner config used to live in `folded/` at the top of this repo. After
pulling, delete what is left of that directory (only untracked backups) before
linking, or the old `~/.config/karabiner` link stays in the way.

### Overriding shared config

Two layers cannot provide the same file. A layer changes shared config through
the include hooks instead: `~/.zshrc.local` is sourced by `.zshrc`, and
`~/.gitconfig.local` is included by `.gitconfig`. A layer ships those as
`home/dot-zshrc.local` and `home/dot-gitconfig.local`.

## Checks

```sh
mise run check   # lint, tests and Lua diagnostics
mise run lint    # formatting and ShellCheck, changing nothing
mise run fmt     # format everything
mise run tools   # install the global mise tools into a temp directory
```

CI runs `check` and `tools`. `tools` checks that a new machine could install
everything in the global mise config, and downloads about 1.5 GB to do it.

The formatters are pinned in `mise.toml`. `dot install` installs them; on a
checkout it has not set up, run `mise trust && mise install` once.

The tests run `dot` against temporary directories and never touch the real
home directory.
