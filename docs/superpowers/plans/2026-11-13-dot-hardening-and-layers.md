# dot Hardening and Layers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `dot` fail loudly and recoverably, support private per-machine layers (e.g. a work repo that cannot live on github.com), and remove dead config from the repo.

**Architecture:** `dot` stays a single zsh script driving GNU Stow. Every linking operation (`link`, `unlink`, prune, `doctor`, `brew bundle`) iterates over a list of _layers_: the public repo first, then any repos listed in an untracked, machine-local layers file. Three environment overrides make the script runnable against fixture directories, so a plain-zsh test file can exercise it without touching `$HOME`.

**Tech Stack:** zsh, GNU Stow 2.4, Homebrew, GitHub Actions (macOS runner). No test framework; tests are a plain zsh script.

**Spec:** None. Requirements come from the 2026-11-13 review conversation and are restated in "Requirements" below.

## Requirements

1. A pre-existing regular file in the target must not leave the user with a bare stow error; `dot link` names the conflicting paths and says what to do.
2. Deleting a directory from a layer must not leave dangling symlinks in `$HOME` after the next `dot link`.
3. `dot doctor` reports drift: unlinked files, symlinks replaced by regular files, dangling links, missing layers, unsatisfied Brewfiles.
4. Extra layers are discovered from a machine-local file; the public repo contains no work paths or URLs.
5. Fresh-machine install must not be able to create `~/.gitconfig` before linking.
6. Small fixes: completion file, exit code for unknown subcommands, `curl -f` in README, guarded `brew shellenv`, early Full Disk Access check, `1password-cli` in the Brewfile, `$HOMEBREW_PREFIX` in `.zshrc`.
7. Remove the unused `astronvim`, `lazyvim` and `nvim` configs.
8. CI runs the syntax check and both test files.
9. Software and config wanted only on personal machines live in a personal layer inside this repo; `dot install` asks once per machine whether to enable it.

## Global Constraints

- `dot` remains one file at `home/dot-local/bin/dot`, shebang `#!/usr/bin/env zsh`, `set -e`.
- macOS on Apple silicon only; `/opt/homebrew` may stay hardcoded.
- No new runtime dependencies beyond what the Brewfile already installs.
- Layer layout is identical for every layer: optional `home/` (stowed with `--dotfiles --no-folding`), optional `folded/` (stowed with `--dotfiles`, folding on), optional `Brewfile`.
- Environment overrides and their defaults, used verbatim everywhere:
  - `DOTFILES` → `$HOME/src/github.com/rickharris/dotfiles`
  - `DOT_TARGET` → `$HOME`
  - `DOT_LAYERS_FILE` → `${XDG_CONFIG_HOME:-$HOME/.config}/dot/layers`
- Layers file format: one directory path per line; blank lines and lines starting with `#` are ignored; a leading `~` expands to `$HOME`.
- All user-facing error lines start with `dot: ` and go to stderr.
- Tests never touch the real `$HOME`; they always set all three overrides to paths under a `mktemp -d` directory.
- Commit style follows the repo: `dot: <lowercase summary>`.

## Review Focus

Conditions the requirements imply that are most likely to bite, each pinned by a test in the task named:

1. A layers-file entry whose directory does not exist (typo, repo not cloned yet) → `dot link` exits 1 naming the path, and links nothing. (Task 2)
2. Two layers providing the same file → `dot link` exits 1 with the conflict hint rather than silently letting one win. (Task 3)
3. A dangling symlink in the target that points somewhere _outside_ every layer → prune must leave it alone. (Task 4)
4. Paths containing spaces, in layer paths and in file names → link, prune and doctor all handle them. (Tasks 2, 4)
5. `/tmp` vs `/private/tmp` style symlinked parents → prune's "points into a layer" comparison must resolve both sides before comparing. (Task 4, covered by using `mktemp -d` fixtures on macOS)

## File Structure

| File | Responsibility |
| --- | --- |
| `home/dot-local/bin/dot` | Modified throughout. Gains `layers`, `stow_pkg`, `prune`, `doctor`, `check_full_disk_access`; `install` is reordered. |
| `tests/dot_test.zsh` | New. Fixture builder, assertions, and all `test_*` functions for `dot`. |
| `layers/personal/` | New. In-repo layer for personal machines: a `Brewfile` and the Karabiner config (moved from `folded/`). |
| `home/dot-local/share/zsh/site-functions/_dot` | Completion; fixed and extended. |
| `Brewfile`, `README.md`, `home/dot-zshrc`, `.prettierignore`, `.gitignore` | Small fixes. |
| `home/dot-config/{astronvim,lazyvim,nvim}/` | Deleted. |
| `.github/workflows/check.yml` | New. CI. |

`tests/`, `docs/`, `layers/` and `.github/` sit at the repo root, outside `home/` and `folded/`, so stow never links them.

---

### Task 1: Test harness, environment overrides, CLI exit codes

**Files:**
- Create: `tests/dot_test.zsh`
- Modify: `home/dot-local/bin/dot` (line 4, `link`, `unlink`, the dispatch at the bottom)

**Interfaces:**
- Produces, in `dot`: variables `dotfiles`, `target`, `layers_file` set from the three overrides in Global Constraints. `link` and `unlink` use `$target` instead of `$HOME`.
- Produces, in `tests/dot_test.zsh`:
  - `setup` — creates `$tmp` via `mktemp -d`, with `$tmp/base/home`, `$tmp/base/folded`, `$tmp/target`; exports the three overrides (`DOT_LAYERS_FILE=$tmp/layers`, file not created).
  - `run_dot <args…>` — runs the repo's `dot` with zsh, capturing combined stdout+stderr in `$out` and exit status in `$rc`; never aborts the test run. It also sets `HOME="$tmp/fakehome"` (an empty directory) for the child process, so that even a `dot` that ignores the overrides cannot reach the real home directory.
  - `assert_rc <n>`, `assert_out_contains <string>`, `assert_link <path> <expected-resolved-target>`, `assert_dir_not_link <path>`, `assert_absent <path>`.
  - A runner that calls `setup` then each function named `test_*`, prints `ok   - name` / `FAIL - name`, removes `$tmp`, and exits 1 if any failed.

- [ ] **Step 1: Write the harness and the first failing tests**

```zsh
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
  run_dot link; run_dot unlink
  assert_rc 0
  assert_absent "$tmp/target/.rc"
}

test_unknown_command_exits_1() { run_dot bogus; assert_rc 1; assert_out_contains "dot link"; }
test_help_exits_0()            { run_dot help;  assert_rc 0; assert_out_contains "dot link"; }
```

- [ ] **Step 2: Run to verify they fail**

Run: `zsh tests/dot_test.zsh`
Expected: all five FAIL. The link tests fail because `dot` still ignores the overrides and looks for the repo under the fake `HOME`; `test_unknown_command_exits_1` fails on exit status 0. Confirm with `git status` and `ls -l ~/.zshrc` that the real home directory is untouched before going on.

- [ ] **Step 3: Implement overrides and exit codes in `dot`**

Replace line 4 with the three variables. Use `$target` in `link`/`unlink`. In the dispatch: `help`, `-h`, `--help` print help and exit 0; any other unknown word prints help to stderr and exits 1. Add `unlink` to `print_help` output if missing (it is present) and leave room for `doctor` (Task 5).

- [ ] **Step 4: Run to verify all five pass**

Run: `zsh tests/dot_test.zsh`
Expected: five `ok` lines, exit 0. Also `zsh -n home/dot-local/bin/dot` exits 0.

- [ ] **Step 5: Commit**

```bash
git add tests/dot_test.zsh home/dot-local/bin/dot
git commit -m "dot: add test harness and target overrides"
```

---

### Task 2: Layers

**Files:**
- Modify: `home/dot-local/bin/dot`
- Test: `tests/dot_test.zsh`

**Interfaces:**
- Produces: `layers` — sets the global array `layer_dirs` to `$dotfiles` followed by each entry of `$layers_file` (format per Global Constraints; missing file means base only). If any listed directory does not exist, prints `dot: layer not found: <path>` to stderr and returns 1.
- Changes: `link` calls `layers` once, then for each layer in order stows `home` (no folding) if `<layer>/home` exists and `folded` if `<layer>/folded` exists. `unlink` does the same in reverse order with `-D`.

- [ ] **Step 1: Write the failing tests**

```zsh
test_layer_is_linked_after_base() {
  mkdir -p "$tmp/work layer/home"                 # space in path on purpose
  touch "$tmp/base/home/dot-rc" "$tmp/work layer/home/dot-rc.local"
  print -rl -- "# comment" "" "$tmp/work layer" > "$tmp/layers"
  run_dot link
  assert_rc 0
  assert_link "$tmp/target/.rc" "$tmp/base/home/dot-rc"
  assert_link "$tmp/target/.rc.local" "$tmp/work layer/home/dot-rc.local"
}

test_missing_layer_fails_before_linking() {
  touch "$tmp/base/home/dot-rc"
  print -rl -- "$tmp/nope" > "$tmp/layers"
  run_dot link
  assert_rc 1
  assert_out_contains "dot: layer not found: $tmp/nope"
  assert_absent "$tmp/target/.rc"
}

test_layer_without_home_is_fine() {
  mkdir -p "$tmp/work/folded/dot-config/tool"; touch "$tmp/work/folded/dot-config/tool/c"
  mkdir -p "$tmp/base/home/dot-config"; touch "$tmp/base/home/dot-config/keep"
  print -rl -- "$tmp/work" > "$tmp/layers"
  run_dot link
  assert_rc 0
  assert_link "$tmp/target/.config/tool" "$tmp/work/folded/dot-config/tool"
}

test_unlink_removes_layer_links() {
  mkdir -p "$tmp/work/home"; touch "$tmp/work/home/dot-w"
  print -rl -- "$tmp/work" > "$tmp/layers"
  run_dot link; run_dot unlink
  assert_absent "$tmp/target/.w"
}
```

- [ ] **Step 2: Run to verify they fail**

Run: `zsh tests/dot_test.zsh`
Expected: the four new tests FAIL; Task 1 tests still pass.

- [ ] **Step 3: Implement `layers` and the loops in `link` / `unlink`**

- [ ] **Step 4: Run to verify all pass**

Run: `zsh tests/dot_test.zsh`
Expected: all `ok`, exit 0.

- [ ] **Step 5: Commit**

```bash
git add tests/dot_test.zsh home/dot-local/bin/dot
git commit -m "dot: link extra layers from a machine-local layers file"
```

---

### Task 3: Conflict reporting

**Files:**
- Modify: `home/dot-local/bin/dot`
- Test: `tests/dot_test.zsh`

**Interfaces:**
- Produces: `stow_pkg <layer> <package> <stow-args…>` — runs stow for one package of one layer against `$target`. On success, silent. On failure, prints stow's own output to stderr followed by exactly:

  ```
  dot: could not link <layer>/<package>.
  dot: move the files listed above out of the way (or merge them into the repo), then re-run `dot link`.
  ```

  and returns 1.
- Changes: every stow invocation in `link` and `unlink` goes through `stow_pkg`.

- [ ] **Step 1: Write the failing tests**

```zsh
test_existing_file_conflict_is_explained() {
  touch "$tmp/base/home/dot-gitconfig"
  print real > "$tmp/target/.gitconfig"
  run_dot link
  assert_rc 1
  assert_out_contains ".gitconfig"
  assert_out_contains "dot: could not link $tmp/base/home."
  assert_out_contains "re-run \`dot link\`"
  [[ "$(<$tmp/target/.gitconfig)" == real ]] || fail "existing file was modified"
}

test_two_layers_same_file_conflict() {
  mkdir -p "$tmp/work/home"
  touch "$tmp/base/home/dot-rc" "$tmp/work/home/dot-rc"
  print -rl -- "$tmp/work" > "$tmp/layers"
  run_dot link
  assert_rc 1
  assert_out_contains "dot: could not link $tmp/work/home."
}
```

Add a `fail <message>` helper to the harness if Task 1 did not need one.

- [ ] **Step 2: Run to verify they fail**

Run: `zsh tests/dot_test.zsh`
Expected: both FAIL on the missing `dot:` lines (exit status is already 1 from stow).

- [ ] **Step 3: Implement `stow_pkg` and route all stow calls through it**

- [ ] **Step 4: Run to verify all pass**

Run: `zsh tests/dot_test.zsh`
Expected: all `ok`.

- [ ] **Step 5: Commit**

```bash
git add tests/dot_test.zsh home/dot-local/bin/dot
git commit -m "dot: explain stow conflicts instead of failing bare"
```

---

### Task 4: Prune dangling links

**Files:**
- Modify: `home/dot-local/bin/dot`
- Test: `tests/dot_test.zsh`

**Interfaces:**
- Produces: `dangling_links` — prints, one per line, every symlink that is (a) broken and (b) whose link text, resolved relative to the link's own directory, lies inside some layer directory. Both sides are compared after resolving symlinked parents (zsh `:A` on the layer dir and on the link's parent dir).
  Search scope: entries directly in `$target` (depth 1), plus the full tree under each `$target/<name>` where `<name>` is the dotfile-translated name of a top-level directory in any layer's `home/` or `folded/` (e.g. `dot-config` → `.config`). `find` must not follow symlinks.
- Produces: `prune` — for each line of `dangling_links`: remove the link, print `pruned: <path>`, then `rmdir` parent directories upward while they are empty, stopping at `$target`.
- Changes: `link` calls `prune` after resolving layers and **before** stowing anything. Pruning first matters when a directory moves from one layer to another: the old link is dangling and would otherwise make stow report a conflict at the new location.

Known limit, to state in a comment above `dangling_links`: if a whole top-level directory (e.g. `home/dot-claude`) is removed from every layer, links under it are no longer in scope. Run `dot unlink` before such a removal.

- [ ] **Step 1: Write the failing tests**

```zsh
test_prune_removed_directory() {
  mkdir -p "$tmp/base/home/dot-config/old app/lua" "$tmp/base/home/dot-config/keep"
  touch "$tmp/base/home/dot-config/old app/init" "$tmp/base/home/dot-config/old app/lua/x" \
        "$tmp/base/home/dot-config/keep/k"
  run_dot link
  rm -r "$tmp/base/home/dot-config/old app"
  run_dot link
  assert_rc 0
  assert_out_contains "pruned: $tmp/target/.config/old app/init"
  assert_absent "$tmp/target/.config/old app"          # emptied dirs are removed too
  assert_link "$tmp/target/.config/keep/k" "$tmp/base/home/dot-config/keep/k"
}

test_prune_keeps_dir_with_other_files() {
  mkdir -p "$tmp/base/home/dot-config/app"; touch "$tmp/base/home/dot-config/app/init" "$tmp/base/home/dot-config/stay"
  run_dot link
  print local > "$tmp/target/.config/app/untracked.json"
  rm -r "$tmp/base/home/dot-config/app"
  run_dot link
  assert_absent "$tmp/target/.config/app/init"
  [[ -f "$tmp/target/.config/app/untracked.json" ]] || fail "untracked file was removed"
}

test_prune_ignores_foreign_dangling_links() {
  mkdir -p "$tmp/base/home/dot-config"; touch "$tmp/base/home/dot-config/k"
  mkdir -p "$tmp/target/.config"
  ln -s "$tmp/elsewhere/gone" "$tmp/target/.config/foreign"
  ln -s "$tmp/elsewhere/gone" "$tmp/target/.toplevel-foreign"
  run_dot link
  [[ -L "$tmp/target/.config/foreign" ]] || fail "foreign dangling link was pruned"
  [[ -L "$tmp/target/.toplevel-foreign" ]] || fail "foreign top-level link was pruned"
}

test_prune_layer_links() {
  mkdir -p "$tmp/work/home/dot-config/tool"; touch "$tmp/work/home/dot-config/tool/c" 
  mkdir -p "$tmp/work/home/dot-config/other"; touch "$tmp/work/home/dot-config/other/o"
  print -rl -- "$tmp/work" > "$tmp/layers"
  run_dot link
  rm -r "$tmp/work/home/dot-config/tool"
  run_dot link
  assert_absent "$tmp/target/.config/tool"
}

test_folded_dir_moves_between_layers() {
  mkdir -p "$tmp/base/home/dot-config" "$tmp/base/folded/dot-config/kb" "$tmp/work/folded/dot-config"
  touch "$tmp/base/home/dot-config/keep" "$tmp/base/folded/dot-config/kb/kb.json"
  print -rl -- "$tmp/work" > "$tmp/layers"
  run_dot link
  mv "$tmp/base/folded/dot-config/kb" "$tmp/work/folded/dot-config/kb"
  run_dot link
  assert_rc 0
  assert_link "$tmp/target/.config/kb" "$tmp/work/folded/dot-config/kb"
}
```

- [ ] **Step 2: Run to verify they fail**

Run: `zsh tests/dot_test.zsh`
Expected: `test_prune_removed_directory`, `test_prune_keeps_dir_with_other_files` and `test_prune_layer_links` FAIL; the foreign-links test passes trivially (keep it as the guard).

- [ ] **Step 3: Implement `dangling_links` and `prune`; call `prune` at the end of `link`**

- [ ] **Step 4: Run to verify all pass**

Run: `zsh tests/dot_test.zsh`
Expected: all `ok`.

- [ ] **Step 5: Commit**

```bash
git add tests/dot_test.zsh home/dot-local/bin/dot
git commit -m "dot: prune dangling links left by removed directories"
```

---

### Task 5: `dot doctor`

**Files:**
- Modify: `home/dot-local/bin/dot` (new function, dispatch entry `doctor`, help line `dot doctor  Check for drift without changing anything`)
- Test: `tests/dot_test.zsh`

**Interfaces:**
- Consumes: `layers`, `layer_dirs`, `dangling_links` (Tasks 2, 4).
- Produces: `doctor` — read-only. Runs every check even after one fails, prints one line per finding, ends with `dot: ok` and exit 0, or `dot: N problem(s) found` on stderr and exit 1. Checks and their finding lines:
  1. Layers resolve (a missing layer is a finding; remaining checks run on the layers that exist): `missing layer: <path>`
  2. For each existing layer/package, `stow -n -v` **without** `--restow` (same folding flags as `link`):
     - each `LINK: <path> => …` line in its output → `not linked: <target>/<path>`
     - a non-zero exit → `conflict in <layer>/<package>:` followed by stow's conflict lines. This is how a symlink replaced by a regular file shows up.
  3. Each line of `dangling_links` → `dangling: <path>`
  4. For each layer with a `Brewfile`, `brew bundle check --no-upgrade --file=…` failing → `brewfile not satisfied: <path>`. Skipped for layers without a Brewfile (so fixture tests never invoke brew).

- [ ] **Step 1: Write the failing tests**

```zsh
test_doctor_clean() {
  touch "$tmp/base/home/dot-rc"
  run_dot link; run_dot doctor
  assert_rc 0
  assert_out_contains "dot: ok"
}

test_doctor_reports_unlinked() {
  touch "$tmp/base/home/dot-rc"
  run_dot doctor
  assert_rc 1
  assert_out_contains "not linked: $tmp/target/.rc"
  assert_absent "$tmp/target/.rc"                      # doctor changes nothing
}

test_doctor_reports_replaced_symlink() {
  touch "$tmp/base/home/dot-rc"
  run_dot link
  print real > "$tmp/target/.rc.tmp"; mv "$tmp/target/.rc.tmp" "$tmp/target/.rc"
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
  print -rl -- "$tmp/nope" > "$tmp/layers"
  run_dot doctor
  assert_rc 1
  assert_out_contains "dangling: $tmp/target/.config/app/init"
  assert_out_contains "missing layer: $tmp/nope"
  assert_out_contains "dot: 2 problem(s) found"
  [[ -L "$tmp/target/.config/app/init" ]] || fail "doctor pruned a link"
}
```

- [ ] **Step 2: Run to verify they fail**

Run: `zsh tests/dot_test.zsh`
Expected: the four new tests FAIL (`doctor` currently falls through to help, exit 1).

- [ ] **Step 3: Implement `doctor`, its dispatch entry and help line**

`layers` returns 1 on a missing directory; `doctor` needs the tolerant behaviour in check 1, so give `layers` an optional first argument `--keep-going` that records missing paths in a global array `missing_layers` and returns 0 with only the existing layers in `layer_dirs`.

- [ ] **Step 4: Run to verify all pass, then run against the real machine**

Run: `zsh tests/dot_test.zsh` → all `ok`.
Run: `dot doctor` → expected `dot: ok` on the current machine (it was clean at review time). Any finding here is real drift; report it rather than fixing it inside this task.

- [ ] **Step 5: Commit**

```bash
git add tests/dot_test.zsh home/dot-local/bin/dot
git commit -m "dot: add doctor command to report drift"
```

---

### Task 6: Install ordering and preflight

**Files:**
- Modify: `home/dot-local/bin/dot` (`install`, `preferences`, line 7, bare-`dot` branch)
- Modify: `Brewfile`

Not covered by the fixture tests (it installs software); verified by syntax check, the existing tests, and a re-run on this machine.

**Interfaces:**
- Produces: `check_full_disk_access` — the existing Safari `defaults write` probe and its help text, moved out of `preferences` unchanged in behaviour (exit 1 with the same message).
- Consumes: `layers`, `layer_dirs`, `link`.

- [ ] **Step 1: Guard the early `brew shellenv`**

Line 7 runs only when `/opt/homebrew/bin/brew` is executable, so a fresh machine prints no error.

- [ ] **Step 2: Reorder `install`**

New order, each step keeping its existing idempotence guard:

1. Homebrew (unchanged).
2. Clone the base repo if `$dotfiles` is missing, using `git clone https://github.com/rickharris/dotfiles.git "$dotfiles"`. The repo is public and `git` comes with the Command Line Tools Homebrew just installed, so this needs no auth.
3. `brew bundle` for the base `Brewfile` (existing check-then-bundle block, including the `share` permissions fix).
4. `link`. Nothing before this point writes into `$HOME` dotfiles, which is the fix for requirement 5.
5. 1Password sign-in wait loop (unchanged; the app and CLI now come from the Brewfile, so drop the two separate `brew install --cask` blocks).
6. `gh auth login` if not authenticated (unchanged flags; drop the separate `brew install gh`, it is in the Brewfile). `~/.gitconfig` is already a symlink whose content has the gh credential helper, so gh has nothing new to write.
7. `brew bundle` for every other layer that has a `Brewfile`, same check-then-bundle form.
8. Claude Code cask migration and install, Karabiner open, `mise install`, headless nvim (all unchanged).

- [ ] **Step 3: Add `cask '1password-cli'` to `Brewfile`, in alphabetical position among the casks**

- [ ] **Step 4: Full Disk Access preflight**

Extract `check_full_disk_access`. Call it at the top of `preferences` and, in the bare-`dot` branch, before `install`.

- [ ] **Step 5: Verify**

Run: `zsh -n home/dot-local/bin/dot` → exit 0.
Run: `zsh tests/dot_test.zsh` → all `ok`.
Run: `brew bundle check --no-upgrade --file=Brewfile` → "The Brewfile's dependencies are satisfied."
Run: `dot install` on this machine → completes with no changes and exit 0 (every step should hit its guard).
Read the diff once specifically for step order against the list in Step 2.

- [ ] **Step 6: Commit**

```bash
git add home/dot-local/bin/dot Brewfile
git commit -m "dot: link before gh auth and check disk access up front"
```

---

### Task 7: Personal layer and install prompt

**Files:**
- Create: `layers/personal/Brewfile`
- Modify: `Brewfile` (remove the entries that move)
- Modify: `home/dot-local/bin/dot` (`install`, `preferences`, dispatch)
- Test: `tests/dot_test.zsh`

The personal layer lives in this public repo at `layers/personal/` and has the standard layer layout. It is only active on machines whose layers file lists it. `layers/` is at the repo root, outside `home/` and `folded/`, so the base stow never links it.

**Interfaces:**
- Consumes: `layers_file`, `dotfiles` (Task 1); the install order from Task 6.
- Produces: `offer_personal_layer` — reads one line from stdin after printing exactly `Install the personal layer (apps and config for personal machines only)? [y/N] `. Creates the parent directory and writes `$layers_file` with this header, followed by the line `$dotfiles/layers/personal` (expanded, absolute) only when the answer starts with `y` or `Y`:

  ```
  # Layers for this machine, one directory per line. Read by `dot`.
  # Edit by hand to add or remove layers.
  ```

  Any other answer, including empty, writes the header only. Writing the file either way is what stops `dot install` asking again.
- Produces: dispatch word `__offer-personal-layer` that calls `offer_personal_layer`. It exists so tests can drive the prompt; it does not appear in help or completion.
- Changes: `install` calls `offer_personal_layer` immediately after the clone step (Task 6, step 2) and before the base `brew bundle`, only when `$layers_file` does not exist **and** stdin is a terminal (`[[ -t 0 ]]`). With no terminal it neither asks nor writes the file.
- Changes: in `preferences`, the Dock loop skips any app path that does not exist, so a machine without the personal layer gets no broken Dock tile.

- [ ] **Step 1: Write the failing tests**

`run_dot` must pass its stdin through to `dot` for these.

```zsh
test_offer_personal_yes_writes_layer() {
  mkdir -p "$tmp/base/layers/personal/home"; touch "$tmp/base/layers/personal/home/dot-personal"
  run_dot __offer-personal-layer <<< "y"
  assert_rc 0
  assert_out_contains "Install the personal layer"
  [[ "$(grep -v '^#' "$tmp/layers")" == "$tmp/base/layers/personal" ]] || fail "layer line missing"
  run_dot link
  assert_rc 0
  assert_link "$tmp/target/.personal" "$tmp/base/layers/personal/home/dot-personal"
}

test_offer_personal_no_writes_header_only() {
  mkdir -p "$tmp/base/layers/personal/home"; touch "$tmp/base/layers/personal/home/dot-personal"
  run_dot __offer-personal-layer <<< ""
  assert_rc 0
  [[ -f "$tmp/layers" ]] || fail "layers file not written"
  [[ -z "$(grep -v '^#' "$tmp/layers")" ]] || fail "unexpected layer line"
  run_dot link
  assert_rc 0
  assert_absent "$tmp/target/.personal"
}

test_offer_personal_creates_parent_dir() {
  export DOT_LAYERS_FILE="$tmp/cfg/dot/layers"
  run_dot __offer-personal-layer <<< "n"
  assert_rc 0
  [[ -f "$tmp/cfg/dot/layers" ]] || fail "layers file not written"
}
```

`setup` must reset `DOT_LAYERS_FILE` for each test so the last one does not leak.

- [ ] **Step 2: Run to verify they fail**

Run: `zsh tests/dot_test.zsh`
Expected: the three new tests FAIL (unknown subcommand, exit 1).

- [ ] **Step 3: Implement `offer_personal_layer`, the dispatch word, the `install` call and the Dock skip**

- [ ] **Step 4: Split the Brewfile**

Move `cask 'discord'`, `cask 'karabiner-elements'` and the commented-out `mas` lines from `Brewfile` to `layers/personal/Brewfile`. Give the new file the same `# vim:ft=ruby` first line. Everything else, including `zen` and `brew 'mas'`, stays in the base. (List confirmed by the user on 2026-11-13.)

- [ ] **Step 5: Move the Karabiner config into the personal layer**

Karabiner is now personal-only, so its config moves with it: `folded/dot-config/karabiner/` → `layers/personal/folded/dot-config/karabiner/`. Move the whole directory with `mv` (not only `git mv`), because it contains the untracked, gitignored `automatic_backups/`; then `git add -A folded layers`. The base `folded/` directory no longer exists afterwards, which Task 2 already allows.

In `install`, the "open Karabiner-Elements on first install" step runs only when `/Applications/Karabiner-Elements.app` exists.

Then run `dot link`. Expected: `pruned: ~/.config/karabiner` (the old link, now dangling) followed by a successful link to the new location. This relies on Task 4 pruning _before_ stowing.

- [ ] **Step 6: Verify**

Run: `zsh tests/dot_test.zsh` → all `ok`.
Run: `zsh -n home/dot-local/bin/dot` → exit 0.
On this machine, which has no layers file yet: run `dot install`, answer `y`, then confirm `cat ~/.config/dot/layers` shows the header and the personal path, `dot doctor` prints `dot: ok`, and a second `dot install` does not ask again.
Run: `readlink ~/.config/karabiner` → ends in `layers/personal/folded/dot-config/karabiner`; Karabiner-Elements still loads its profiles (check the menu bar app shows the existing profiles).
Run: `brew bundle check --no-upgrade --file=Brewfile` and the same for `layers/personal/Brewfile` → both satisfied.

- [ ] **Step 7: Commit**

```bash
git add -A layers folded Brewfile home/dot-local/bin/dot tests/dot_test.zsh
git commit -m "dot: add personal layer and offer it during install"
```

---

### Task 8: Completion, README, zshrc

**Files:**
- Modify: `home/dot-local/share/zsh/site-functions/_dot`
- Modify: `README.md`
- Modify: `home/dot-zshrc`
- Modify: `.prettierignore`

- [ ] **Step 1: Fix completion**

First line becomes `#compdef dot`. Values: `install`, `link`, `unlink`, `doctor`, `prefs`, `help`, each with the same description text as `print_help`.

- [ ] **Step 2: README**

Bootstrap line uses `curl -fsSL`. Add two short sections: "Commands" (one line per subcommand, matching `print_help`) and "Layers" (the layers file location and format from Global Constraints, the layer layout, the in-repo personal layer and the one-time install prompt that enables it, and the rule that a layer overrides shared config through `~/.zshrc.local` / `~/.gitconfig.local` style includes because two layers cannot own the same file). Do not mention any work path, host or URL.

- [ ] **Step 3: `.zshrc`**

Replace all five `$(brew --prefix)` calls with `$HOMEBREW_PREFIX` and remove the now-redundant `type brew` guard around the completions `FPATH` line. (`HOMEBREW_PREFIX` is exported by the `brew shellenv` line `dot install` writes to `~/.zprofile`.)

- [ ] **Step 4: `.prettierignore`**

Its two entries point at paths that no longer exist. Replace with `layers/personal/folded/dot-config/karabiner/karabiner.json` and `home/dot-config/nvim-pack/nvim-pack-lock.json`.

- [ ] **Step 5: Verify**

Run: `zsh -n home/dot-zshrc` → exit 0.
Run: `zsh -ic 'echo $HOMEBREW_PREFIX; whence -w _dot; exit'` → prints `/opt/homebrew` and `_dot: function`, with no "no such file" errors.
Run: `time zsh -ic exit` before and after; startup should not be slower.

- [ ] **Step 6: Commit**

```bash
git add home/dot-local/share/zsh/site-functions/_dot README.md home/dot-zshrc .prettierignore
git commit -m "dot: fix completion, document layers, use HOMEBREW_PREFIX"
```

---

### Task 9: Remove unused Neovim configs

**Files:**
- Delete: `home/dot-config/astronvim/`, `home/dot-config/lazyvim/`, `home/dot-config/nvim/`
- Modify: `.gitignore` (drop the `home/dot-config/lazyvim/lazyvim.json` line)
- Keep: `home/dot-config/nvim-pack/`, `home/dot-config/nvim-shared/` (`nvim-pack/init.lua` loads `nvim-shared`)

Depends on Task 4: this is the directory-removal case prune exists for.

- [ ] **Step 1: Confirm nothing active references the three configs**

Run: `grep -rn "astronvim\|lazyvim\|config/nvim['\"/]" home/dot-zshrc home/dot-tmux.conf home/dot-local home/dot-config/nvim-pack home/dot-config/nvim-shared home/dot-config/ghostty home/dot-claude`
Expected: no hits that load those configs (prose mentions in `nvim-shared/lua/pr_reviews/README.md` are fine; update any that describe the deleted `nvim` config as a consumer).

- [ ] **Step 2: Delete and re-link**

```bash
git rm -r home/dot-config/astronvim home/dot-config/lazyvim home/dot-config/nvim
dot link
```

Expected: a `pruned:` line for each previously linked file, exit 0.

- [ ] **Step 3: Verify**

Run: `dot doctor` → `dot: ok`.
Run: `find ~/.config/astronvim ~/.config/lazyvim ~/.config/nvim -type l 2>/dev/null` → no output. Directories that remain hold only untracked local files (e.g. `lazyvim.json`); leave them and list them in the task report for the user to delete by hand, along with `~/.local/share/{astronvim,lazyvim,nvim}` and `~/.local/state/{astronvim,lazyvim,nvim}`. Do not delete those automatically.
Run: `nvim --headless +q` → exit 0 (still starts with `NVIM_APPNAME=nvim-pack`).
Run: `nvim -l home/dot-config/nvim-shared/tests/query_spec.lua` → all `ok`.

- [ ] **Step 4: Commit**

```bash
git add -A home/dot-config .gitignore
git commit -m "nvim: remove unused astronvim, lazyvim and lazy.nvim configs"
```

---

### Task 10: CI

**Files:**
- Create: `.github/workflows/check.yml`

- [ ] **Step 1: Write the workflow**

Name `check`; triggers `push` to `main` and `pull_request`; one job on `macos-latest` with steps:

1. `actions/checkout`
2. `brew install stow neovim`
3. `zsh -n home/dot-local/bin/dot && zsh -n home/dot-zshrc`
4. `zsh tests/dot_test.zsh`
5. `nvim -l home/dot-config/nvim-shared/tests/query_spec.lua`

No secrets, no caching.

- [ ] **Step 2: Verify locally**

Run steps 3–5 by hand from the repo root → each exits 0.
After the branch is pushed, confirm the `check` run is green: `gh run watch` (or `gh run list --workflow check --limit 1`).

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/check.yml
git commit -m "ci: run dot tests and syntax checks on macOS"
```

---

## Out of Scope

- Renaming `nvim-pack` to `nvim` and dropping `NVIM_APPNAME`.
- Creating the work layer repo itself; this plan only makes `dot` able to consume one.
- Per-layer install hooks beyond `Brewfile`. Add when a layer first needs one.
- Merging files that have no include mechanism (e.g. `~/.claude/settings.json`) across layers; one layer owns such a file whole.
