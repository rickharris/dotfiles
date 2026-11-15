#!/bin/sh
# PostToolUse hook for Write and Edit: keep an edited file formatted, and for
# the zsh files check that it still works. Exit 2 hands a failure back to the
# agent that made the edit.
#
# Tools run through `mise exec`, so they are the versions pinned in mise.toml,
# the same ones CI uses.
#
# - Markdown, JSON, YAML, Lua, TOML and sh: formatted in place.
# - dot, its tests and .zshrc: syntax and formatting are checked and reported,
#   never fixed. shfmt's zsh support is incomplete and dot is live on this
#   machine, so nothing rewrites it unattended. dot and its tests also run the
#   test suite, which only touches temp directories.

file=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')
root=${CLAUDE_PROJECT_DIR:-$PWD}

# Only files in this repo, and only when the pinned tools can be run.
case "$file" in
"$root"/*) ;;
*) exit 0 ;;
esac
if [ ! -f "$file" ] || ! command -v mise >/dev/null 2>&1; then
  exit 0
fi
cd "$root" || exit 0

# Runs a formatter that rewrites the file, reporting only if it fails, which
# means the file does not parse.
format() {
  if ! output=$(mise exec -- "$@" "$file" 2>&1); then
    echo "$1 could not format $file:" >&2
    echo "$output" | tail -n 20 >&2
    exit 2
  fi
}

run_tests=0
case "$file" in
*/home/dot-local/bin/dot | */tests/dot_test.zsh) run_tests=1 ;;
*/home/dot-zshrc) ;;
*.md | *.json | *.yml | *.yaml)
  format prettier --write --log-level warn
  exit 0
  ;;
*.lua)
  format stylua
  exit 0
  ;;
*.toml)
  format taplo fmt
  exit 0
  ;;
*.sh)
  format shfmt -i 2 -w
  exit 0
  ;;
*) exit 0 ;;
esac

failed=0

if ! output=$(zsh -n "$file" 2>&1); then
  failed=1
  echo "zsh -n failed for $file:" >&2
  echo "$output" >&2
elif [ "$run_tests" = 1 ] && ! output=$(zsh tests/dot_test.zsh 2>&1); then
  failed=1
  echo "dot tests failed after editing $file:" >&2
  # Passing tests are noise here; keep the failures and their details.
  echo "$output" | grep -v '^ok ' | tail -n 40 >&2
fi

if ! output=$(mise exec -- shfmt -ln zsh -i 2 -d "$file" 2>&1); then
  failed=1
  echo "$file is not formatted as \`shfmt -ln zsh -i 2\` would format it:" >&2
  echo "$output" | tail -n 40 >&2
fi

if [ "$failed" = 1 ]; then
  exit 2
fi
