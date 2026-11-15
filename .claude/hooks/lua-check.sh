#!/bin/sh
# Stop hook: if the agent edited Lua since the last clean check, run
# lua-language-server over the repo and hand what it finds back to the agent
# with exit 2.
#
# after-edit.sh leaves the marker. The check takes about fifteen seconds,
# nearly all of it the server indexing the plugins, so it runs once here
# instead of after every edit.

root=${CLAUDE_PROJECT_DIR:-$PWD}
marker=$root/.claude/lua-check-pending

if [ ! -f "$marker" ] || ! command -v mise >/dev/null 2>&1; then
  exit 0
fi
cd "$root" || exit 0

output=$(mise exec -- tests/lua_check.sh 2>&1)
case $? in
0) rm -f "$marker" ;;
1)
  echo "lua-language-server found problems:" >&2
  echo "$output" | tail -n 40 >&2
  exit 2
  ;;
*)
  # The check could not run, which the agent cannot fix. Tell the user and
  # let the agent stop.
  rm -f "$marker"
  echo "$output" | tail -n 20 >&2
  exit 1
  ;;
esac
