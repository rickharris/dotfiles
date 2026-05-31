#!/bin/sh
# Claude Code status line — mirrors p10k lean prompt style (dir + git + model)
# The model segment wraps to a second line only when the full line would
# overflow the terminal width; short paths stay on a single line.

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')

# Shorten home directory to ~
home="$HOME"
short_cwd="${cwd#$home}"
if [ "$short_cwd" != "$cwd" ]; then
  short_cwd="~$short_cwd"
fi

# Git branch and status (skip optional locks)
branch=""
git_status=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  staged=$(git -C "$cwd" diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
  unstaged=$(git -C "$cwd" diff --name-only 2>/dev/null | wc -l | tr -d ' ')
  untracked=$(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

  if [ -n "$branch" ]; then
    git_status=" $branch"
    [ "$staged" -gt 0 ]    && git_status="$git_status +$staged"
    [ "$unstaged" -gt 0 ]  && git_status="$git_status !$unstaged"
    [ "$untracked" -gt 0 ] && git_status="$git_status ?$untracked"
  fi
fi

# Context usage (only shown after first API call)
context_part=""
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
  context_part=" ctx:$(printf '%.0f' "$used")%"
fi

# Terminal width: Claude Code exports COLUMNS; tput and 80 are fallbacks.
# It also pads the status line by 2 columns on each side and ellipsis-truncates
# anything wider, so the usable width is COLUMNS - 4 (measured empirically).
cols="${COLUMNS:-}"
[ -z "$cols" ] && cols=$(tput cols 2>/dev/null)
[ -z "$cols" ] && cols=80
cols=$((cols - 4))
[ "$cols" -lt 1 ] && cols=1

# Control characters built once (command substitution would strip a newline)
ESC=$(printf '\033')
RESET="${ESC}[0m"
GS=$(printf '\035')   # field separator inside each token record
NL='
'

# Build a list of wrappable tokens, one per line: "sep<GS>color<GS>text".
# sep is "none" (joins directly to previous token, e.g. path parts) or
# "space" (a breakable space precedes it). text is the visible, un-colored run.
tokens=""
add_token() {
  tokens="${tokens}${1}${GS}${2}${GS}${3}${NL}"
}

# Path, broken into "/"-delimited components so deep paths can fold at slashes
rest="$short_cwd"
first="${rest%%/*}"
add_token none blue "$first"
rest="${rest#"$first"}"
while [ -n "$rest" ]; do
  comp="${rest#/}"; comp="${comp%%/*}"
  add_token none blue "/$comp"
  rest="${rest#/"$comp"}"
done

# Git status parts (branch + counts), each a space-separated breakable token
for part in $git_status; do
  add_token space green "$part"
done

# Context percentage, then the model — both dim
[ -n "$context_part" ] && add_token space dim "${context_part# }"
add_token space dim "[$model]"

# Greedily pack tokens into lines no wider than $cols (visible width)
out=""
line_len=0
while IFS="$GS" read -r sep color text; do
  [ -z "$color" ] && continue
  case "$color" in
    blue)  c="${ESC}[34m" ;;
    green) c="${ESC}[32m" ;;
    dim)   c="${ESC}[2m" ;;
  esac
  piece="${c}${text}${RESET}"
  len=${#text}
  if [ "$line_len" -eq 0 ]; then
    out="${out}${piece}"; line_len=$len
  else
    [ "$sep" = space ] && pad=1 || pad=0
    if [ $((line_len + pad + len)) -gt "$cols" ]; then
      out="${out}${NL}${piece}"; line_len=$len
    else
      [ "$pad" -eq 1 ] && { out="${out} "; line_len=$((line_len + 1)); }
      out="${out}${piece}"; line_len=$((line_len + len))
    fi
  fi
done <<EOF
$tokens
EOF

printf '%s' "$out"
