#!/bin/bash
# Installs every tool in the global mise config into a temp directory, the
# way a new machine would, and removes it again.
#
# mise vets an npm package only when it installs one: it refuses a package
# with few downloads, or one whose release carries weaker publisher evidence
# than an earlier release did. A tool that is already installed is never
# checked again, so a version bump can pass every other check here and then
# stop `dot install`. This is the check that fails instead.
#
# It downloads about 1.5 GB.
#
# Exit status: 0 if every tool installed, 1 if one did not, 3 if the check
# could not run.

set -u
cd "$(dirname "$0")/.." || exit 3

fail() {
  echo "tools_check: $1" >&2
  exit 3
}

if ! command -v mise >/dev/null 2>&1; then
  fail "mise is not installed"
fi
config=$PWD/home/dot-config/mise/config.toml
if [ ! -f "$config" ]; then
  fail "no global mise config at $config"
fi

tmp=$(mktemp -d) || fail "could not make a temp directory"
trap 'rm -rf "$tmp"' EXIT

# Run from an empty directory, so that this repo's own mise.toml is not read
# and only the global config is installed.
mkdir "$tmp/empty" || fail "could not make a temp directory"
cd "$tmp/empty" || exit 3

if ! MISE_GLOBAL_CONFIG_FILE=$config \
  MISE_DATA_DIR=$tmp/data \
  MISE_CACHE_DIR=$tmp/cache \
  MISE_STATE_DIR=$tmp/state \
  mise install; then
  echo "tools_check: mise could not install every tool in $config" >&2
  exit 1
fi
