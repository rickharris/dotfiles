#!/bin/zsh
# Tests for home/dot-config/zsh/dotfiles-prompt.zsh, the prompt segment that shows
# how far behind the dotfiles are. Run with: zsh tests/dot_prompt_test.zsh
#
# The segment reads a cache file, so every test points XDG_CACHE_HOME at a
# fresh temp directory. Powerlevel10k is not loaded: a stand-in p10k function
# records what the segment asks it to draw.

zmodload zsh/datetime

repo=$(cd "$(dirname "$0")/.." && pwd -P)
segment=$repo/home/dot-config/zsh/dotfiles-prompt.zsh

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
  # A stand-in for the dotfiles repo, so the real one's git history does not
  # decide what the tests see. head is the file git appends to whenever the
  # checkout moves.
  _dot_prompt_repo=$tmp/repo
  mkdir -p "$tmp/repo/.git/logs"
  head=$tmp/repo/.git/logs/HEAD
  _dot_prompt_launched_at=0
  _dot_prompt_launched_head=
}

# Sets a file's modification time to a number of seconds ago.
age() {
  local stamp
  strftime -s stamp %Y%m%d%H%M.%S $((EPOCHSECONDS - $2))
  touch -t "$stamp" "$1"
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
  echo 0 >"$cache"
  age "$cache" 7200
  if ! _dot_prompt_stale; then
    fail "expected a cache file from two hours ago to be stale"
  fi
}

# A manual git pull, or switching branch, moves the checkout without dot
# knowing, so the count has to be worked out again.
test_stale_when_checkout_moved_since() {
  echo 2 >"$cache"
  age "$cache" 600
  touch "$head"
  if ! _dot_prompt_stale; then
    fail "expected a checkout that moved after the last check to be stale"
  fi
}

test_not_stale_when_checkout_moved_before() {
  touch "$head"
  age "$head" 600
  echo 2 >"$cache"
  if _dot_prompt_stale; then
    fail "expected a check newer than the last move not to be stale"
  fi
}

test_check_wanted_when_stale() {
  if ! _dot_prompt_should_check; then
    fail "expected a check to be wanted when there is no cache file"
  fi
}

test_check_not_wanted_when_fresh() {
  echo 0 >"$cache"
  if _dot_prompt_should_check; then
    fail "expected no check when the cache file is fresh"
  fi
}

# If the check cannot write the cache file, or dot is not on PATH, the file
# stays stale. That must not start a check on every prompt.
test_check_not_wanted_again_while_still_stale() {
  _dot_prompt_should_check
  if _dot_prompt_should_check; then
    fail "expected no second check straight after the first"
  fi
}

test_check_wanted_again_when_checkout_moves() {
  _dot_prompt_should_check
  touch "$head"
  if ! _dot_prompt_should_check; then
    fail "expected another check once the checkout moved"
  fi
}

test_show_leaves_no_match_variable() {
  echo 3 >"$cache"
  unset MATCH
  show
  if ((${+MATCH})); then
    fail "expected the segment not to leave MATCH set in the shell"
  fi
}

# .zshrc allows there to be no ~/.p10k.zsh, in which case nothing has set the
# list of segments.
test_source_without_p10k_config() {
  local out
  out=$(zsh -fc 'source "$1" && print -r -- "[$POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS]"' zsh "$segment" 2>&1)
  if [[ $out != "[dotfiles]" ]]; then
    fail "expected only [dotfiles] and no errors, got: $out"
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
