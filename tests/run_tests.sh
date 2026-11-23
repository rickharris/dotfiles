#!/bin/bash
# Checks the syntax of every shell script, then runs every test in tests/
# whose name ends in _test and a shell extension. shell_files.sh finds the
# scripts, so a new one is checked without being listed anywhere.
#
# - sh and bash are parsed with /bin/bash, the 3.2 macOS ships, because `dot`
#   has to run on it.
# - *_test.bash runs with /bin/bash, *_test.zsh with zsh, and *_test.sh runs
#   itself, by its shebang.
#
# Every test runs, even after one fails; the exit status is 1 if any did.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

failed=0

for file in $(tests/shell_files.sh sh); do
  if ! /bin/bash -n "$file"; then
    failed=1
  fi
done
for file in $(tests/shell_files.sh zsh); do
  if ! zsh -n "$file"; then
    failed=1
  fi
done

for test in tests/*_test.*; do
  case $test in
  *.bash) runner=(/bin/bash "$test") ;;
  *.zsh) runner=(zsh "$test") ;;
  *.sh) runner=("$test") ;;
  *) continue ;;
  esac
  echo "# $test"
  if ! "${runner[@]}"; then
    echo "run_tests: $test failed" >&2
    failed=1
  fi
done

exit "$failed"
