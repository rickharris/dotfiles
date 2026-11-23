#!/bin/bash
# Fetches every plugin in Neovim's lockfile, at its locked revision, into the
# directory given. CI uses this to give tests/lua_check.sh the plugins without
# starting Neovim with the full config.
#
# Usage: scripts/fetch_nvim_plugins.sh DIRECTORY

set -eu

if [ $# -ne 1 ]; then
  echo "usage: $0 DIRECTORY" >&2
  exit 2
fi
dest=$1
lock=$(dirname "$0")/../home/dot-config/nvim/nvim-pack-lock.json
mkdir -p "$dest"

# Fetches one revision of one plugin, without its history.
fetch() {
  local dir=$dest/$1
  if [ -d "$dir/.git" ]; then
    return 0
  fi
  git init -q "$dir" &&
    git -C "$dir" fetch -q --depth 1 "$2" "$3" &&
    git -C "$dir" -c advice.detachedHead=false checkout -q FETCH_HEAD
}

pids=""
while IFS=$'\t' read -r name src rev; do
  fetch "$name" "$src" "$rev" &
  pids="$pids $!"
done < <(jq -r '.plugins | to_entries[] | [.key, .value.src, .value.rev] | @tsv' "$lock")

failed=0
for pid in $pids; do
  if ! wait "$pid"; then
    failed=1
  fi
done
if [ "$failed" = 1 ]; then
  echo "fetch_nvim_plugins: could not fetch every plugin" >&2
  exit 1
fi
