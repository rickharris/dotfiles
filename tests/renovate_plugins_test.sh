#!/bin/bash
# Checks that Renovate still sees every Neovim plugin it is meant to update.
#
# renovate.json finds the plugins with a regular expression over vim.pack's
# lockfile. If Neovim changes how it writes that file, the expression stops
# matching and Renovate stops proposing updates without saying anything. This
# applies the same expression and compares the count with the lockfile.
#
# Plugins locked to a version range are left out on purpose: Renovate does
# not update those.
#
# Exit status: 0 if every plugin matched, 1 if not, 3 if the check could not
# run.

set -u
cd "$(dirname "$0")/.." || exit 3

lock=home/dot-config/nvim/nvim-pack-lock.json
for tool in jq perl; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "renovate_plugins_test: $tool is not installed" >&2
    exit 3
  fi
done

pattern=$(jq -r '.customManagers[] | select(.datasourceTemplate == "git-refs") | .matchStrings[0]' renovate.json)
if [ -z "$pattern" ] || [ "$pattern" = null ]; then
  echo "renovate_plugins_test: no git-refs manager in renovate.json" >&2
  exit 1
fi

expected=$(jq '[.plugins[] | select(has("version") | not)] | length' "$lock")
matched=$(PATTERN=$pattern perl -0777 -ne 'my $n = 0; $n++ while /$ENV{PATTERN}/g; print $n' "$lock")

if [ "$matched" != "$expected" ]; then
  echo "renovate_plugins_test: renovate.json matches $matched of the $expected plugins that follow a branch in $lock" >&2
  exit 1
fi
echo "ok   - renovate.json matches all $expected plugins that follow a branch"
