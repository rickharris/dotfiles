#!/bin/bash
# Tests for home/dot-local/bin/dot. Run with: /bin/bash tests/dot_test.bash
#
# dot has to run on the bash that ships with macOS, which is 3.2, because it
# bootstraps a machine before anything newer is installed. So these tests
# and dot itself are always run with /bin/bash, never a newer bash on PATH.
#
# Every test runs dot against fixture directories under a fresh temp dir. The
# real home directory is never touched: run_dot points the three DOT overrides
# at the fixture and also swaps HOME for an empty directory.

# dot installs stow with Homebrew when it is missing. The tests must never
# install anything on the machine they run on, so refuse to start without it.
if ! command -v stow >/dev/null 2>&1; then
  print -ru2 -- "stow is not installed; install it before running these tests."
  exit 1
fi

repo=$(cd "$(dirname "$0")/.." && pwd -P)
dot=$repo/home/dot-local/bin/dot

setup() {
  # mktemp hands back a path through a symlinked parent on macOS (/var is a
  # link to /private/var). Most tests use the resolved path; tmp_raw keeps the
  # original for the tests that need the two to differ.
  tmp_raw=$(mktemp -d)
  tmp=$(cd "$tmp_raw" && pwd -P)
  mkdir -p "$tmp/base/home" "$tmp/base/folded" "$tmp/target" "$tmp/fakehome"
  export DOTFILES="$tmp/base"
  export DOT_TARGET="$tmp/target"
  export DOT_LAYERS_FILE="$tmp/layers"
  # dot keeps how far behind the checkout is under the cache directory.
  export XDG_CACHE_HOME="$tmp/cache"
  # Keep git away from the config of whoever runs the tests, and give it an
  # identity so the fixtures can commit.
  export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
  export GIT_AUTHOR_NAME=Test GIT_AUTHOR_EMAIL=test@example.com
  export GIT_COMMITTER_NAME=Test GIT_COMMITTER_EMAIL=test@example.com
}

teardown() {
  rm -rf "$tmp"
}

# Runs dot, leaving combined output in $out and the exit status in $rc. Stdin
# is passed through so tests can answer prompts.
run_dot() {
  out=$(HOME="$tmp/fakehome" /bin/bash "$dot" "$@" 2>&1)
  rc=$?
}

fail() {
  echo "       $*"
  test_failed=1
}

assert_rc() {
  [[ $rc -eq $1 ]] || fail "expected exit $1, got $rc. Output: $out"
}

assert_out_contains() {
  [[ $out == *"$1"* ]] || fail "expected output to contain '$1'. Output: $out"
}

assert_link() {
  if [[ ! -L $1 ]]; then
    fail "expected a symlink at $1"
    return
  fi
  # -ef is true when both paths resolve to the same file.
  [[ $1 -ef $2 ]] || fail "expected $1 to resolve to $2"
}

assert_dir_not_link() {
  [[ -d $1 && ! -L $1 ]] || fail "expected a real directory at $1"
}

assert_absent() {
  [[ ! -e $1 && ! -L $1 ]] || fail "expected nothing at $1"
}

assert_file_is() {
  if [[ ! -f $1 ]]; then
    fail "expected a file at $1"
    return
  fi
  [[ $(<"$1") == "$2" ]] || fail "expected $1 to hold '$2', got '$(<"$1")'"
}

# Makes a directory (the base repo unless one is given) a git repo on main
# with one commit, pushed to a new bare repo that is its origin.
git_fixture() {
  local dir=${1:-$tmp/base} bare=${2:-$tmp/origin.git}
  git init -q --bare -b main "$bare"
  git -C "$dir" init -q -b main
  touch "$dir/README"
  git -C "$dir" add README
  git -C "$dir" commit -q -m first
  git -C "$dir" remote add origin "$bare"
  git -C "$dir" push -q -u origin main
}

# Adds one commit to main in a bare repo, through a second clone of it, so
# the fixture repo falls one commit further behind its origin.
upstream_commit() {
  local bare=${1:-$tmp/origin.git}
  if [[ ! -d $bare.clone ]]; then
    git clone -q "$bare" "$bare.clone"
  fi
  git -C "$bare.clone" commit -q --allow-empty -m upstream
  git -C "$bare.clone" push -q origin main
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

test_layer_is_linked_after_base() {
  mkdir -p "$tmp/work layer/home" # space in the path on purpose
  touch "$tmp/base/home/dot-rc" "$tmp/work layer/home/dot-rc.local"
  printf '%s\n' "# comment" "" "$tmp/work layer" >"$tmp/layers"
  run_dot link
  assert_rc 0
  assert_link "$tmp/target/.rc" "$tmp/base/home/dot-rc"
  assert_link "$tmp/target/.rc.local" "$tmp/work layer/home/dot-rc.local"
}

test_missing_layer_fails_before_linking() {
  touch "$tmp/base/home/dot-rc"
  printf '%s\n' "$tmp/nope" >"$tmp/layers"
  run_dot link
  assert_rc 1
  assert_out_contains "dot: layer not found: $tmp/nope"
  assert_absent "$tmp/target/.rc"
}

test_layer_without_home_is_fine() {
  mkdir -p "$tmp/work/folded/dot-config/tool"
  touch "$tmp/work/folded/dot-config/tool/c"
  mkdir -p "$tmp/base/home/dot-config"
  touch "$tmp/base/home/dot-config/keep"
  printf '%s\n' "$tmp/work" >"$tmp/layers"
  run_dot link
  assert_rc 0
  assert_link "$tmp/target/.config/tool" "$tmp/work/folded/dot-config/tool"
}

test_unlink_removes_layer_links() {
  mkdir -p "$tmp/work/home"
  touch "$tmp/work/home/dot-w"
  printf '%s\n' "$tmp/work" >"$tmp/layers"
  run_dot link
  assert_link "$tmp/target/.w" "$tmp/work/home/dot-w"
  run_dot unlink
  assert_absent "$tmp/target/.w"
}

test_existing_file_conflict_is_explained() {
  touch "$tmp/base/home/dot-gitconfig"
  echo real >"$tmp/target/.gitconfig"
  run_dot link
  assert_rc 1
  assert_out_contains ".gitconfig"
  assert_out_contains "dot: could not link $tmp/base/home."
  assert_out_contains "re-run \`dot link\`"
  [[ "$(<"$tmp/target/.gitconfig")" == real ]] || fail "existing file was modified"
}

test_two_layers_same_file_conflict() {
  mkdir -p "$tmp/work/home"
  touch "$tmp/base/home/dot-rc" "$tmp/work/home/dot-rc"
  printf '%s\n' "$tmp/work" >"$tmp/layers"
  run_dot link
  assert_rc 1
  assert_out_contains "dot: could not link $tmp/work/home."
}

test_prune_removed_directory() {
  mkdir -p "$tmp/base/home/dot-config/old app/lua" "$tmp/base/home/dot-config/keep"
  touch "$tmp/base/home/dot-config/old app/init" "$tmp/base/home/dot-config/old app/lua/x" \
    "$tmp/base/home/dot-config/keep/k"
  run_dot link
  rm -r "$tmp/base/home/dot-config/old app"
  run_dot link
  assert_rc 0
  assert_out_contains "pruned: $tmp/target/.config/old app/init"
  assert_absent "$tmp/target/.config/old app" # emptied directories go too
  assert_link "$tmp/target/.config/keep/k" "$tmp/base/home/dot-config/keep/k"
}

test_prune_keeps_dir_with_other_files() {
  mkdir -p "$tmp/base/home/dot-config/app"
  touch "$tmp/base/home/dot-config/app/init" "$tmp/base/home/dot-config/stay"
  run_dot link
  echo local >"$tmp/target/.config/app/untracked.json"
  rm -r "$tmp/base/home/dot-config/app"
  run_dot link
  assert_absent "$tmp/target/.config/app/init"
  [[ -f "$tmp/target/.config/app/untracked.json" ]] || fail "untracked file was removed"
}

test_prune_ignores_foreign_dangling_links() {
  mkdir -p "$tmp/base/home/dot-config"
  touch "$tmp/base/home/dot-config/k"
  mkdir -p "$tmp/target/.config"
  ln -s "$tmp/elsewhere/gone" "$tmp/target/.config/foreign"
  ln -s "$tmp/elsewhere/gone" "$tmp/target/.toplevel-foreign"
  run_dot link
  [[ -L "$tmp/target/.config/foreign" ]] || fail "foreign dangling link was pruned"
  [[ -L "$tmp/target/.toplevel-foreign" ]] || fail "foreign top-level link was pruned"
}

test_prune_layer_links() {
  mkdir -p "$tmp/work/home/dot-config/tool" "$tmp/work/home/dot-config/other"
  touch "$tmp/work/home/dot-config/tool/c" "$tmp/work/home/dot-config/other/o"
  printf '%s\n' "$tmp/work" >"$tmp/layers"
  run_dot link
  rm -r "$tmp/work/home/dot-config/tool"
  run_dot link
  assert_absent "$tmp/target/.config/tool"
}

test_folded_dir_moves_between_layers() {
  mkdir -p "$tmp/base/home/dot-config" "$tmp/base/folded/dot-config/kb" "$tmp/work/folded/dot-config"
  touch "$tmp/base/home/dot-config/keep" "$tmp/base/folded/dot-config/kb/kb.json"
  printf '%s\n' "$tmp/work" >"$tmp/layers"
  run_dot link
  mv "$tmp/base/folded/dot-config/kb" "$tmp/work/folded/dot-config/kb"
  rm -r "$tmp/base/folded" # the base no longer has a folded package at all
  run_dot link
  assert_rc 0
  assert_link "$tmp/target/.config/kb" "$tmp/work/folded/dot-config/kb"
}

test_doctor_clean() {
  touch "$tmp/base/home/dot-rc"
  run_dot link
  run_dot doctor
  assert_rc 0
  assert_out_contains "dot: ok"
}

test_doctor_reports_unlinked() {
  touch "$tmp/base/home/dot-rc"
  run_dot doctor
  assert_rc 1
  assert_out_contains "not linked: $tmp/target/.rc"
  assert_absent "$tmp/target/.rc" # doctor changes nothing
}

test_doctor_reports_replaced_symlink() {
  touch "$tmp/base/home/dot-rc"
  run_dot link
  echo real >"$tmp/target/.rc.tmp"
  mv "$tmp/target/.rc.tmp" "$tmp/target/.rc"
  run_dot doctor
  assert_rc 1
  assert_out_contains "conflict in $tmp/base/home"
  assert_out_contains ".rc"
}

test_doctor_reports_dangling_and_missing_layer() {
  mkdir -p "$tmp/base/home/dot-config/app" "$tmp/base/home/dot-config/keep"
  touch "$tmp/base/home/dot-config/app/init" "$tmp/base/home/dot-config/keep/k"
  run_dot link
  rm -r "$tmp/base/home/dot-config/app"
  printf '%s\n' "$tmp/nope" >"$tmp/layers"
  run_dot doctor
  assert_rc 1
  assert_out_contains "dangling: $tmp/target/.config/app/init"
  assert_out_contains "missing layer: $tmp/nope"
  assert_out_contains "dot: 2 problem(s) found"
  [[ -L "$tmp/target/.config/app/init" ]] || fail "doctor pruned a link"
}

test_offer_personal_yes_writes_layer() {
  mkdir -p "$tmp/base/layers/personal/home"
  touch "$tmp/base/layers/personal/home/dot-personal"
  run_dot __offer-personal-layer <<<"y"
  assert_rc 0
  assert_out_contains "Install the personal layer"
  [[ "$(grep -v '^#' "$tmp/layers")" == "$tmp/base/layers/personal" ]] || fail "layer line missing"
  run_dot link
  assert_rc 0
  assert_link "$tmp/target/.personal" "$tmp/base/layers/personal/home/dot-personal"
}

test_offer_personal_no_writes_header_only() {
  mkdir -p "$tmp/base/layers/personal/home"
  touch "$tmp/base/layers/personal/home/dot-personal"
  run_dot __offer-personal-layer <<<""
  assert_rc 0
  [[ -f "$tmp/layers" ]] || fail "layers file not written"
  ! grep -qv '^#' "$tmp/layers" || fail "unexpected layer line"
  run_dot link
  assert_rc 0
  assert_absent "$tmp/target/.personal"
}

test_offer_personal_creates_parent_dir() {
  export DOT_LAYERS_FILE="$tmp/cfg/dot/layers"
  run_dot __offer-personal-layer <<<"n"
  assert_rc 0
  [[ -f "$tmp/cfg/dot/layers" ]] || fail "layers file not written"
}

test_prune_survives_unreadable_directory() {
  mkdir -p "$tmp/base/home/dot-aaa/locked" "$tmp/base/home/dot-zzz/app" "$tmp/base/home/dot-zzz/keep"
  touch "$tmp/base/home/dot-aaa/locked/f" "$tmp/base/home/dot-zzz/app/init" "$tmp/base/home/dot-zzz/keep/k"
  run_dot link
  rm -r "$tmp/base/home/dot-zzz/app"
  chmod 000 "$tmp/target/.aaa/locked"
  run_dot doctor
  chmod 700 "$tmp/target/.aaa/locked"
  assert_rc 1
  assert_out_contains "dangling: $tmp/target/.zzz/app/init"
}

test_prune_with_symlinked_parent_paths() {
  [[ $tmp_raw != "$tmp" ]] || return 0 # nothing to tell apart on this system
  export DOTFILES="$tmp_raw/base" DOT_TARGET="$tmp_raw/target"
  mkdir -p "$tmp/base/home/dot-config/app" "$tmp/base/home/dot-config/keep"
  touch "$tmp/base/home/dot-config/app/init" "$tmp/base/home/dot-config/keep/k"
  run_dot link
  rm -r "$tmp/base/home/dot-config/app"
  run_dot link
  assert_rc 0
  assert_absent "$tmp/target/.config/app"
}

test_missing_base_repo_is_an_error() {
  export DOTFILES="$tmp/nope"
  run_dot link
  assert_rc 1
  assert_out_contains "dot: dotfiles repo not found: $tmp/nope"
  run_dot doctor
  assert_rc 1
  assert_out_contains "dot: dotfiles repo not found: $tmp/nope"
}

test_link_hints_when_personal_layer_was_never_offered() {
  mkdir -p "$tmp/base/layers/personal/home"
  touch "$tmp/base/home/dot-rc"
  run_dot link
  assert_rc 0
  assert_out_contains "dot: the personal layer is not enabled"
  assert_out_contains "$tmp/layers"
}

test_link_does_not_hint_once_layers_file_exists() {
  mkdir -p "$tmp/base/layers/personal/home"
  touch "$tmp/base/home/dot-rc"
  run_dot __offer-personal-layer <<<"n"
  run_dot link
  assert_rc 0
  [[ $out != *"personal layer is not enabled"* ]] || fail "hint shown although the question was answered"
}

test_unlink_failure_says_unlink() {
  touch "$tmp/base/home/dot-rc"
  run_dot link
  # A directory where the package has a file makes stow refuse to unstow.
  rm "$tmp/target/.rc"
  mkdir "$tmp/target/.rc"
  run_dot unlink
  assert_rc 1
  assert_out_contains "dot: could not unlink $tmp/base/home."
  assert_out_contains "re-run \`dot unlink\`"
  [[ $out != *"could not link"* ]] || fail "unlink failure used the link wording"
}

test_tilde_slash_expands_to_home() {
  mkdir -p "$tmp/fakehome/work/home"
  touch "$tmp/fakehome/work/home/dot-w"
  # A literal tilde is the point: dot has to expand it, not the shell.
  # shellcheck disable=SC2088
  printf '%s\n' '~/work' >"$tmp/layers"
  run_dot link
  assert_rc 0
  assert_link "$tmp/target/.w" "$tmp/fakehome/work/home/dot-w"
}

test_tilde_user_is_not_expanded() {
  touch "$tmp/base/home/dot-rc"
  printf '%s\n' "~bob/work" >"$tmp/layers"
  run_dot link
  assert_rc 1
  assert_out_contains "dot: layer path must be absolute: ~bob/work"
  assert_absent "$tmp/target/.rc"
}

test_relative_layer_path_is_rejected() {
  # The directory exists relative to the repo root, where the tests run, so
  # only the absolute-path rule can reject it.
  touch "$tmp/base/home/dot-rc"
  printf '%s\n' "tests" >"$tmp/layers"
  run_dot link
  assert_rc 1
  assert_out_contains "dot: layer path must be absolute: tests"
  assert_absent "$tmp/target/.rc"
}

test_doctor_reports_relative_layer_path() {
  touch "$tmp/base/home/dot-rc"
  run_dot link
  printf '%s\n' "tests" >"$tmp/layers"
  run_dot doctor
  assert_rc 1
  assert_out_contains "layer path must be absolute: tests"
  assert_out_contains "dot: 1 problem(s) found"
}

test_check_writes_behind_count() {
  git_fixture
  upstream_commit
  upstream_commit
  run_dot update --check
  assert_rc 0
  assert_out_contains "dot: 2 commit(s) behind origin/main; run \`dot update\`"
  assert_file_is "$tmp/cache/dot/behind" 2
}

test_check_writes_zero_when_up_to_date() {
  git_fixture
  run_dot update --check
  assert_rc 0
  assert_out_contains "dot: up to date with origin/main"
  assert_file_is "$tmp/cache/dot/behind" 0
}

test_check_writes_zero_when_ahead() {
  git_fixture
  git -C "$tmp/base" commit -q --allow-empty -m local
  run_dot update --check
  assert_file_is "$tmp/cache/dot/behind" 0
}

test_check_writes_zero_on_other_branch() {
  git_fixture
  upstream_commit
  git -C "$tmp/base" checkout -q -b topic
  run_dot update --check
  assert_rc 0
  assert_out_contains "dot: not on the main branch, so not checked"
  assert_file_is "$tmp/cache/dot/behind" 0
}

test_check_writes_zero_on_detached_head() {
  git_fixture
  upstream_commit
  git -C "$tmp/base" checkout -q --detach
  run_dot update --check
  assert_rc 0
  assert_file_is "$tmp/cache/dot/behind" 0
}

test_check_keeps_old_count_when_fetch_fails() {
  git_fixture
  upstream_commit
  run_dot update --check
  git -C "$tmp/base" remote set-url origin "$tmp/gone.git"
  run_dot update --check
  assert_rc 1
  assert_out_contains "dot: could not fetch from origin"
  assert_file_is "$tmp/cache/dot/behind" 1
}

test_check_without_origin_fails() {
  git -C "$tmp/base" init -q -b main
  git -C "$tmp/base" commit -q --allow-empty -m first
  run_dot update --check
  assert_rc 1
  assert_out_contains "dot: could not fetch from origin"
  assert_file_is "$tmp/cache/dot/behind" ""
}

test_check_outside_git_repo_touches_cache() {
  run_dot update --check
  assert_rc 1
  assert_out_contains "dot: not a git repository: $tmp/base"
  [[ -f $tmp/cache/dot/behind ]] || fail "expected the cache file to exist"
}

test_check_survives_unwritable_cache() {
  git_fixture
  touch "$tmp/cache" # a file where the cache directory should go
  run_dot update --check
  assert_rc 0
  assert_out_contains "dot: up to date with origin/main"
}

test_update_rejects_unknown_option() {
  run_dot update --bogus
  assert_rc 1
  assert_out_contains "dot install"
}

test_doctor_reports_behind() {
  git_fixture
  upstream_commit
  run_dot doctor
  assert_rc 1
  assert_out_contains "behind origin/main by 1 commit(s): run \`dot update\`"
  assert_out_contains "dot: 1 problem(s) found"
}

test_doctor_ok_when_up_to_date() {
  git_fixture
  run_dot doctor
  assert_rc 0
  assert_out_contains "dot: ok"
}

test_doctor_ignores_behind_on_other_branch() {
  git_fixture
  upstream_commit
  git -C "$tmp/base" checkout -q -b topic
  run_dot doctor
  assert_rc 0
}

test_doctor_uses_last_fetch_when_offline() {
  git_fixture
  upstream_commit
  git -C "$tmp/base" fetch -q origin main
  git -C "$tmp/base" remote set-url origin "$tmp/gone.git"
  run_dot doctor
  assert_rc 1
  assert_out_contains "behind origin/main by 1 commit(s)"
}

test_doctor_ok_without_origin() {
  git -C "$tmp/base" init -q -b main
  git -C "$tmp/base" commit -q --allow-empty -m first
  run_dot doctor
  assert_rc 0
  assert_out_contains "dot: ok"
}

test_pull_fast_forwards_base() {
  git_fixture
  upstream_commit
  run_dot __pull
  assert_rc 0
  local have want
  have=$(git -C "$tmp/base" rev-parse HEAD)
  want=$(git -C "$tmp/origin.git" rev-parse main)
  [[ $have == "$want" ]] ||
    fail "expected base to match origin/main"
}

test_pull_resets_cache() {
  git_fixture
  upstream_commit
  run_dot update --check
  run_dot __pull
  assert_file_is "$tmp/cache/dot/behind" 0
}

test_pull_refuses_other_branch() {
  git_fixture
  upstream_commit
  git -C "$tmp/base" checkout -q -b topic
  run_dot __pull
  assert_rc 1
  assert_out_contains "dot: $tmp/base is not on the main branch"
  [[ $(git -C "$tmp/base" rev-list --count HEAD) -eq 1 ]] ||
    fail "expected no new commits"
}

test_pull_refuses_detached_head() {
  git_fixture
  git -C "$tmp/base" checkout -q --detach
  run_dot __pull
  assert_rc 1
  assert_out_contains "dot: $tmp/base is not on the main branch"
}

test_pull_keeps_unrelated_local_edits() {
  git_fixture
  upstream_commit
  echo edited >"$tmp/base/README"
  run_dot __pull
  assert_rc 0
  assert_file_is "$tmp/base/README" edited
}

test_pull_succeeds_when_ahead() {
  git_fixture
  git -C "$tmp/base" commit -q --allow-empty -m local
  run_dot __pull
  assert_rc 0
}

test_pull_diverged_fails() {
  git_fixture
  upstream_commit
  git -C "$tmp/base" commit -q --allow-empty -m local
  run_dot __pull
  assert_rc 1
  assert_out_contains "dot: could not fast-forward $tmp/base."
}

test_pull_updates_layer_repo() {
  git_fixture
  mkdir -p "$tmp/work layer"
  git_fixture "$tmp/work layer" "$tmp/work.git"
  upstream_commit "$tmp/work.git"
  printf '%s\n' "$tmp/work layer" >"$tmp/layers"
  run_dot __pull
  assert_rc 0
  local have want
  have=$(git -C "$tmp/work layer" rev-parse HEAD)
  want=$(git -C "$tmp/work.git" rev-parse main)
  [[ $have == "$want" ]] ||
    fail "expected the layer to match its origin"
}

test_pull_skips_layers_that_are_not_repos() {
  git_fixture
  mkdir -p "$tmp/base/layers/personal" "$tmp/plain"
  printf '%s\n' "$tmp/base/layers/personal" "$tmp/plain" >"$tmp/layers"
  run_dot __pull
  assert_rc 0
}

test_pull_outside_git_repo_fails() {
  run_dot __pull
  assert_rc 1
  assert_out_contains "dot: not a git repository: $tmp/base"
}

test_help_lists_update() {
  run_dot help
  assert_out_contains "Pull the latest dotfiles and run install"
}

failures=0
for t in $(declare -F | awk '{ print $3 }' | grep '^test_' | sort); do
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
