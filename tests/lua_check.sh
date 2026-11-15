#!/bin/bash
# Reports what lua-language-server finds in the Lua in this repo: the
# diagnostics Neovim shows, checked from the command line.
#
# Most of them come from the plugins' type annotations, so Neovim's runtime
# and the plugins have to be on disk. .luarc.json tells the server where: the
# Neovim that mise installs, and the directory vim.pack installs plugins in.
# CI fills that directory with tests/fetch_nvim_plugins.sh.
#
# Exit status: 0 for no diagnostics, 1 for diagnostics, 3 if the check could
# not run.

set -u
cd "$(dirname "$0")/.." || exit 3

fail() {
  echo "lua_check: $1" >&2
  exit 3
}

if ! command -v lua-language-server >/dev/null 2>&1; then
  fail "lua-language-server is not installed"
fi

# The server ignores a library path that does not exist, and then reports
# every use of a plugin as a problem. Say what is missing instead. These are
# the paths in .luarc.json.
runtime=$HOME/.local/share/mise/installs/neovim/latest/share/nvim/runtime/lua
plugins=$HOME/.local/share/nvim/site/pack/core/opt
if [ ! -d "$runtime" ]; then
  fail "Neovim's runtime is not at $runtime"
fi
if ! ls "$plugins"/*/lua >/dev/null 2>&1; then
  fail "no plugins in $plugins"
fi

tmp=$(mktemp -d) || exit 3
trap 'rm -rf "$tmp"' EXIT

output=$(lua-language-server --check . --logpath "$tmp/log" \
  --checklevel=Hint 2>&1)
status=$?
if [ "$status" = 0 ]; then
  exit 0
fi

# The server draws a progress bar and prints each diagnostic more than once,
# with colours. Keep one plain `file:line:column [severity] message` each.
found=$(printf '%s\n' "$output" | tr '\r' '\n' |
  sed $'s/\x1b\\[[0-9;]*m//g' |
  grep -E '^[^ ]+:[0-9]+:[0-9]+ \[' | sort -u -t: -k1,1 -k2,2n -k3,3n)
if [ -z "$found" ]; then
  echo "lua_check: lua-language-server failed:" >&2
  printf '%s\n' "$output" | tail -n 20 >&2
  exit 3
fi
printf '%s\n' "$found" >&2
exit 1
