#!/bin/bash
# Starts Neovim with this checkout's config the way a new machine does: in an
# empty home directory, so that it installs every plugin from the lockfile,
# builds the parsers and runs the build hooks. Fails if anything reports an
# error on the way.
#
# The other checks only read the Lua. This is the one that runs it, so it is
# what notices a Neovim or plugin version the config does not work with.
#
# It uses the Neovim that mise installs, clones about forty plugins and needs
# the tree-sitter CLI and a C compiler for the parsers.
#
# Exit status: 0 for a clean start, 1 for errors, 3 if the check could not
# run.

set -u
cd "$(dirname "$0")/.." || exit 3
repo=$PWD

fail() {
  echo "nvim_start: $1" >&2
  exit 3
}

# The same Neovim tests/lua_check.sh reads the runtime of.
nvim=$HOME/.local/share/mise/installs/neovim/latest/bin/nvim
if [ ! -x "$nvim" ]; then
  fail "no Neovim at $nvim: run \`mise install\` for the global config"
fi
for tool in tree-sitter jq; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    fail "$tool is not installed"
  fi
done

# A short path, because Neovim names each cached Lua file after the full path
# of its source, and a long temp directory pushes that past the limit for a
# file name.
tmp=$(mktemp -d /tmp/nvim_start.XXXXXX) || fail "could not make a temp directory"
# A plugin can leave a process behind that is still writing when Neovim quits,
# so removing the directory gets a second try.
cleanup() {
  rm -rf "$tmp" 2>/dev/null || {
    sleep 2
    rm -rf "$tmp"
  }
}
trap cleanup EXIT

# The config is copied, not linked, so that Neovim writing its lockfile cannot
# change this checkout. nvim-shared is read from ~/.config by the config.
mkdir -p "$tmp/.config" || fail "could not make a temp directory"
cp -R "$repo/home/dot-config/nvim" "$tmp/.config/nvim" || fail "could not copy the config"
ln -s "$repo/home/dot-config/nvim-shared" "$tmp/.config/nvim-shared" || fail "could not link nvim-shared"

env -u XDG_CONFIG_HOME -u XDG_DATA_HOME -u XDG_STATE_HOME -u XDG_CACHE_HOME \
  HOME="$tmp" "$nvim" --headless +q >"$tmp/log" 2>&1
status=$?
cat "$tmp/log"
echo

if [ "$status" -ne 0 ]; then
  echo "nvim_start: Neovim exited with status $status" >&2
  exit 1
fi
# Neovim's own errors start with an E and a number. A Lua error brings a
# stack traceback, and the plugins that build things say "error" or "failed".
# v:errmsg is no use here: plugins set it with commands they silence.
if grep -E -i -q '(^|[^[:alnum:]])E[0-9]+:|stack traceback|error|failed' "$tmp/log"; then
  echo "nvim_start: Neovim reported errors while starting" >&2
  exit 1
fi
# A start that never read the config is clean too, so check that it did what
# the config asks for: every plugin in the lockfile is on disk.
for name in $(jq -r '.plugins | keys[]' "$repo/home/dot-config/nvim/nvim-pack-lock.json"); do
  if [ ! -d "$tmp/.local/share/nvim/site/pack/core/opt/$name" ]; then
    echo "nvim_start: Neovim did not install $name" >&2
    exit 1
  fi
done
if ! cmp -s "$tmp/.config/nvim/nvim-pack-lock.json" "$repo/home/dot-config/nvim/nvim-pack-lock.json"; then
  echo "nvim_start: starting Neovim changed the lockfile:" >&2
  diff "$repo/home/dot-config/nvim/nvim-pack-lock.json" "$tmp/.config/nvim/nvim-pack-lock.json" >&2
  exit 1
fi
echo "nvim_start: ok"
