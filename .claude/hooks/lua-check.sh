#!/bin/sh
# PreToolUse hook for Bash: before a `git commit`, if any Lua differs from
# HEAD, run lua-language-server over the Neovim config. Exit 2 blocks the
# commit and hands what it found back to the agent.
#
# The check takes about fifteen seconds, nearly all of it the server indexing
# the plugins, so it runs here instead of after every edit.

command=$(jq -r '.tool_input.command // empty')
if ! printf '%s\n' "$command" | grep -Eq '(^|[^[:alnum:]_.-])git( [^;&|]*)? commit( |$)'; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 0
if ! command -v mise >/dev/null 2>&1 ||
  [ -z "$(git status --porcelain -- '*.lua' 2>/dev/null)" ]; then
  exit 0
fi

output=$(mise exec -- tests/lua_check.sh 2>&1)
case $? in
0) ;;
1)
  echo "Not committing: lua-language-server found problems." >&2
  echo "$output" | tail -n 40 >&2
  exit 2
  ;;
*)
  # The check could not run, which the agent cannot fix. Tell the user and
  # let the commit go ahead; CI runs the same check.
  echo "$output" | tail -n 20 >&2
  exit 1
  ;;
esac
