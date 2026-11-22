#!/bin/sh
# PostToolUse hook for Write and Edit: keep an edited file formatted and
# linted, and run the tests for dot. Exit 2 hands a failure back to the
# agent that made the edit.
#
# Tools run through `mise exec`, so they are the versions pinned in mise.toml,
# the same ones CI uses.
#
# - Markdown, JSON, YAML, Lua, TOML, sh and bash: formatted in place.
# - Markdown is also fixed with rumdl, before formatting, and what rumdl
#   cannot fix is reported.
# - Lua is also marked for lua-check.sh, which runs lua-language-server once
#   the agent stops, because that takes too long to do after every edit.
# - sh and bash are also linted with ShellCheck.
# - dot and its tests also run the test suite, with the bash macOS ships. The
#   tests only touch temp directories.
# - .zshrc and the zsh completion file: syntax and formatting are checked and
#   reported, never fixed, because shfmt's zsh support is incomplete.

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

# Reports what ShellCheck finds in the file.
lint() {
  if ! output=$(mise exec -- shellcheck "$file" 2>&1); then
    echo "shellcheck found problems in $file:" >&2
    echo "$output" | tail -n 40 >&2
    exit 2
  fi
}

case "$file" in
*/home/dot-local/bin/dot | */tests/dot_test.bash)
  format shfmt -i 2 -w
  lint
  # dot has to work on the bash macOS ships, so always test with /bin/bash.
  if ! output=$(/bin/bash tests/dot_test.bash 2>&1); then
    echo "dot tests failed after editing $file:" >&2
    # Passing tests are noise here; keep the failures and their details.
    echo "$output" | grep -v '^ok ' | tail -n 40 >&2
    exit 2
  fi
  ;;
*/home/dot-zshrc | */site-functions/_dot)
  failed=0
  if ! output=$(zsh -n "$file" 2>&1); then
    failed=1
    echo "zsh -n failed for $file:" >&2
    echo "$output" >&2
  fi
  if ! output=$(mise exec -- shfmt -ln zsh -i 2 -d "$file" 2>&1); then
    failed=1
    echo "$file is not formatted as \`shfmt -ln zsh -i 2\` would format it:" >&2
    echo "$output" | tail -n 40 >&2
  fi
  if [ "$failed" = 1 ]; then
    exit 2
  fi
  ;;
*.md)
  # rumdl fmt exits 0 even when it leaves problems, so check afterwards.
  format rumdl fmt
  format oxfmt --no-error-on-unmatched-pattern
  if ! output=$(mise exec -- rumdl check "$file" 2>&1); then
    echo "rumdl found problems in $file:" >&2
    echo "$output" | tail -n 40 >&2
    exit 2
  fi
  ;;
*.json | *.yml | *.yaml | *.toml)
  # A file on the ignore list in .oxfmtrc.json matches nothing; that is not
  # an error.
  format oxfmt --no-error-on-unmatched-pattern
  ;;
*.lua)
  format stylua
  touch .claude/lua-check-pending
  ;;
*.sh | *.bash)
  format shfmt -i 2 -w
  lint
  ;;
esac
