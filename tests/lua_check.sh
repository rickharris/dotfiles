#!/bin/bash
# Reports what lua-language-server finds in the Lua in this repo: the
# diagnostics Neovim shows, checked from the command line.
#
# Most of them come from the plugins' type annotations, so the plugins have to
# be on disk. The server is configured by .luarc.jsonc, which points at where
# mise installs Neovim and where vim.pack installs plugins. CI has neither, so
# it sets LUA_CHECK_PLUGINS to a directory filled by
# tests/fetch_nvim_plugins.sh, and the check then runs with a copy of the
# config that points there and at the runtime of whichever nvim is on PATH.
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

tmp=$(mktemp -d) || exit 3
trap 'rm -rf "$tmp"' EXIT

if [ -n "${LUA_CHECK_PLUGINS:-}" ]; then
  for tool in jq nvim; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      fail "$tool is not installed"
    fi
  done
  plugins=$LUA_CHECK_PLUGINS
  runtime=$(nvim --clean --headless \
    -c 'lua io.stdout:write(vim.env.VIMRUNTIME)' -c q 2>/dev/null)/lua
  # .luarc.jsonc has no comments, so jq can read it.
  if ! jq --arg runtime "$runtime" --arg plugins "$plugins" \
    '.workspace.library = [$runtime, "${3rd}/luv/library", $plugins]' \
    .luarc.jsonc >"$tmp/luarc.json"; then
    fail "could not read .luarc.jsonc"
  fi
  set -- --configpath "$tmp/luarc.json"
else
  plugins=$HOME/.local/share/nvim/site/pack/core/opt
  runtime=$HOME/.local/share/mise/installs/neovim/latest/share/nvim/runtime/lua
  set --
fi
if [ ! -d "$runtime" ]; then
  fail "Neovim's runtime is not at $runtime"
fi
if ! ls "$plugins"/*/lua >/dev/null 2>&1; then
  fail "no plugins in $plugins"
fi

output=$(lua-language-server --check . "$@" --logpath "$tmp/log" \
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
