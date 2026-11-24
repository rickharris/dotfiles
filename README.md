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

Renovate proposes updates to the tools in the mise configs, to the GitHub
Actions, and to the Neovim plugins, by changing the commits in
`nvim-pack-lock.json`. The plugins share one pull request, which Renovate
keeps up to date until it is merged. Merging one and running `dot update`
applies it.

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
- `install` is an executable script that `dot install` runs from the layer's
  directory, for setup that a Brewfile or a linked file cannot do, such as
  logging in to another account with `gh auth login`.

### Install scripts

`dot install` runs each layer's `install` in layer order. The scripts run
after the dotfiles are linked and 1Password and `gh` are set up, and before the
Brewfiles, so a script can ask for input but cannot use anything a Brewfile
installs. If one fails, `dot install` stops there.

`dot update` ends by running `dot install`, so a script runs again on every
update. Make it skip what is already done, for example by checking
`gh auth status` before logging in.

### The personal layer

`layers/personal` in this repo holds apps and config that only belong on
personal machines. The first time `dot install` runs on a machine it asks
whether to enable it, and records the answer by writing the layers file. To
change the answer later, edit that file.

### Private layers

A layer can live in a private repo that belongs to another GitHub account,
such as an enterprise-managed one. That repo's README holds the one-liner
above with two options added, where `<dot-url>` is the URL that one fetches:

```sh
bash <(curl -fsSL <dot-url>) \
  --layer https://github.com/<owner>/<repo> --user <login>
```

After the usual GitHub login, `dot install` adds `<login>` to `gh` if it does
not have it yet, and switches the active account back. It then clones the
layer to `~/src/github.com/<owner>/<repo>`, adds it to the layers file and
links it. The layer's `install` script and `Brewfile` run with the others.

The checkout gets a credential helper of its own, which asks `gh` for
`<login>`'s token. So `dot update` pulls it with that account, while
everything else keeps using the active one. Running the one-liner again on a
machine that has the layer changes nothing.

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
mise run check   # lint, tests, Lua diagnostics and a Neovim start
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
