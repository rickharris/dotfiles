#!/usr/bin/env zsh
# Tests for home/dot-local/bin/dot. Run with: zsh tests/dot_test.zsh
#
# Every test runs dot against fixture directories under a fresh temp dir. The
# real home directory is never touched: run_dot points the three DOT overrides
# at the fixture and also swaps HOME for an empty directory.

repo=${0:A:h:h}
dot=$repo/home/dot-local/bin/dot

setup() {
  tmp=$(mktemp -d)
  tmp=${tmp:A}
  mkdir -p "$tmp/base/home" "$tmp/base/folded" "$tmp/target" "$tmp/fakehome"
  export DOTFILES="$tmp/base"
  export DOT_TARGET="$tmp/target"
  export DOT_LAYERS_FILE="$tmp/layers"
}

teardown() {
  rm -rf "$tmp"
}

# Runs dot, leaving combined output in $out and the exit status in $rc. Stdin
# is passed through so tests can answer prompts.
run_dot() {
  out=$(HOME="$tmp/fakehome" zsh "$dot" "$@" 2>&1)
  rc=$?
}

fail() {
  print -r -- "       $*"
  test_failed=1
}

assert_rc() {
  [[ $rc -eq $1 ]] || fail "expected exit $1, got $rc. Output: $out"
}

assert_out_contains() {
  [[ $out == *"$1"* ]] || fail "expected output to contain '$1'. Output: $out"
}

assert_link() {
  [[ -L $1 ]] || { fail "expected a symlink at $1"; return }
  [[ ${1:A} == ${2:A} ]] || fail "expected $1 to resolve to $2, got ${1:A}"
}

assert_dir_not_link() {
  [[ -d $1 && ! -L $1 ]] || fail "expected a real directory at $1"
}

assert_absent() {
  [[ ! -e $1 && ! -L $1 ]] || fail "expected nothing at $1"
}

test_link_home_is_not_folded() {
  mkdir -p "$tmp/base/home/dot-config/app"
  touch "$tmp/base/home/dot-config/app/conf" "$tmp/base/home/dot-rc"
  run_dot link
  assert_rc 0
  assert_link "$tmp/target/.rc" "$tmp/base/home/dot-rc"
  assert_dir_not_link "$tmp/target/.config/app"
  assert_link "$tmp/target/.config/app/conf" "$tmp/base/home/dot-config/app/conf"
}

test_link_folded_links_directory() {
  mkdir -p "$tmp/base/home/dot-config" "$tmp/base/folded/dot-config/kb"
  touch "$tmp/base/home/dot-config/keep" "$tmp/base/folded/dot-config/kb/kb.json"
  run_dot link
  assert_rc 0
  assert_link "$tmp/target/.config/kb" "$tmp/base/folded/dot-config/kb"
}

test_unlink_removes_links() {
  touch "$tmp/base/home/dot-rc"
  run_dot link
  run_dot unlink
  assert_rc 0
  assert_absent "$tmp/target/.rc"
}

test_unknown_command_exits_1() {
  run_dot bogus
  assert_rc 1
  assert_out_contains "dot link"
}

test_help_exits_0() {
  run_dot help
  assert_rc 0
  assert_out_contains "dot link"
}

failures=0
for t in ${(ok)functions[(I)test_*]}; do
  test_failed=0
  setup
  $t
  teardown
  if ((test_failed)); then
    failures=$((failures + 1))
    print -r -- "FAIL - $t"
  else
    print -r -- "ok   - $t"
  fi
done

if ((failures)); then
  print -r -- "$failures test(s) failed"
  exit 1
fi
