#!/bin/zsh
# Tests for home/dot-config/zsh/dot-prompt.zsh, the prompt segment that shows
# how far behind the dotfiles are. Run with: zsh tests/dot_prompt_test.zsh
#
# The segment reads a cache file, so every test points XDG_CACHE_HOME at a
# fresh temp directory. Powerlevel10k is not loaded: a stand-in p10k function
# records what the segment asks it to draw.

zmodload zsh/datetime

repo=$(cd "$(dirname "$0")/.." && pwd -P)
segment=$repo/home/dot-config/zsh/dot-prompt.zsh

typeset -a p10k_calls
p10k() {
  p10k_calls+=("$*")
}

# What the Powerlevel10k config would have set before the segment is loaded.
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs)
source "$segment"

setup() {
  tmp=$(mktemp -d)
  export XDG_CACHE_HOME=$tmp
  mkdir -p "$tmp/dot"
  cache=$tmp/dot/behind
  p10k_calls=()
}

teardown() {
  rm -rf "$tmp"
}

fail() {
  echo "       $*"
  test_failed=1
}

# Runs the display half of the segment, keeping what it writes to stderr.
show() {
  _dot_prompt_show 2>"$tmp/stderr"
}

assert_no_segment() {
  if ((${#p10k_calls})); then
    fail "expected no segment, got: $p10k_calls"
  fi
}

test_show_behind() {
  echo 3 >"$cache"
  show
  if [[ ${#p10k_calls} -ne 1 || $p10k_calls[1] != "segment -f 4 -t dot ⇣3" ]]; then
    fail "expected one segment 'dot ⇣3' in colour 4, got: $p10k_calls"
  fi
}

test_show_nothing_when_zero() {
  echo 0 >"$cache"
  show
  assert_no_segment
}

test_show_nothing_when_empty() {
  : >"$cache"
  show
  assert_no_segment
}

test_show_nothing_when_missing() {
  show
  assert_no_segment
}

test_show_nothing_when_garbage() {
  echo abc >"$cache"
  show
  assert_no_segment
  if [[ -s $tmp/stderr ]]; then
    fail "expected nothing on stderr, got: $(<"$tmp/stderr")"
  fi
}

test_stale_when_missing() {
  if ! _dot_prompt_stale; then
    fail "expected a missing cache file to be stale"
  fi
}

test_not_stale_when_fresh() {
  echo 0 >"$cache"
  if _dot_prompt_stale; then
    fail "expected a cache file written just now not to be stale"
  fi
}

test_stale_after_an_hour() {
  local stamp
  echo 0 >"$cache"
  strftime -s stamp %Y%m%d%H%M.%S $((EPOCHSECONDS - 7200))
  touch -t "$stamp" "$cache"
  if ! _dot_prompt_stale; then
    fail "expected a cache file from two hours ago to be stale"
  fi
}

test_segment_is_first_on_right() {
  if [[ $POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[1] != dotfiles ]]; then
    fail "expected dotfiles first, got: $POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS"
  fi
}

test_segment_is_added_once() {
  source "$segment"
  if [[ "$POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS" != "dotfiles status background_jobs" ]]; then
    fail "expected one dotfiles element, got: $POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS"
  fi
}

failures=0
for t in $(print -l ${(ok)functions} | grep '^test_'); do
  test_failed=0
  setup
  $t
  teardown
  if ((test_failed)); then
    failures=$((failures + 1))
    echo "FAIL - $t"
  else
    echo "ok   - $t"
  fi
done

if ((failures)); then
  echo "$failures test(s) failed"
  exit 1
fi
