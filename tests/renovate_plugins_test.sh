#!/bin/bash
# Checks that Renovate still sees every Neovim plugin.
#
# renovate.json finds the plugins with regular expressions: over vim.pack's
# lockfile for every plugin, and over init.lua for the ones that follow a
# tagged release, whose tag is written there too. If Neovim changes how it
# writes the lockfile, or a plugin is declared in a way the expressions do not
# expect, Renovate stops proposing updates for it without saying anything.
# This applies the same expressions and compares the counts with the lockfile.
#
# Exit status: 0 if every plugin matched, 1 if not, 3 if the check could not
# run.

set -u
cd "$(dirname "$0")/.." || exit 3

lock=home/dot-config/nvim/nvim-pack-lock.json
init=home/dot-config/nvim/init.lua
for tool in jq perl; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "renovate_plugins_test: $tool is not installed" >&2
    exit 3
  fi
done

# Prints how many times the expressions of the managers for one file match
# it: count_matches <text in the manager's file pattern> <file>
count_matches() {
  local total=0 pattern n
  while IFS= read -r pattern; do
    n=$(PATTERN=$pattern perl -0777 -ne 'my $n = 0; $n++ while /$ENV{PATTERN}/g; print $n' "$2")
    total=$((total + n))
  done < <(jq -r --arg file "$1" \
    '.customManagers[] | select(.managerFilePatterns[0] | contains($file)) | .matchStrings[]' renovate.json)
  echo "$total"
}

failed=0

plugins=$(jq '.plugins | length' "$lock")
matched=$(count_matches nvim-pack-lock "$lock")
if [ "$matched" != "$plugins" ]; then
  echo "renovate_plugins_test: renovate.json matches $matched of the $plugins plugins in $lock" >&2
  failed=1
else
  echo "ok   - renovate.json matches all $plugins plugins in the lockfile"
fi

tagged=$(jq '[.plugins[] | select(has("version"))] | length' "$lock")
matched=$(count_matches 'init\.lua' "$init")
if [ "$matched" != "$tagged" ]; then
  echo "renovate_plugins_test: renovate.json matches $matched of the $tagged tagged plugins in $init" >&2
  failed=1
else
  echo "ok   - renovate.json matches all $tagged tagged plugins in init.lua"
fi

exit "$failed"
