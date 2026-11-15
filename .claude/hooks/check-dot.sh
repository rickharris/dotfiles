#!/bin/sh
# PostToolUse hook for Write and Edit. After a change to one of the zsh files
# below, check its syntax and formatting, and for dot and its tests also run
# the tests, which only touch temp directories. Exit 2 hands the failure back
# to the agent that made the edit.
#
# Formatting is reported, never fixed: dot is live on this machine, so nothing
# rewrites it unattended.

file=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')

case "$file" in
*/home/dot-local/bin/dot | */tests/dot_test.zsh) run_tests=1 ;;
*/home/dot-zshrc) run_tests=0 ;;
*) exit 0 ;;
esac

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

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

if command -v shfmt >/dev/null 2>&1 && ! output=$(shfmt -ln zsh -i 2 -d "$file" 2>&1); then
  failed=1
  echo "$file is not formatted as \`shfmt -ln zsh -i 2\` would format it:" >&2
  echo "$output" | tail -n 40 >&2
fi

if [ "$failed" = 1 ]; then
  exit 2
fi
