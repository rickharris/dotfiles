#!/bin/bash
# Lists the shell scripts in this repo, one group at a time, so the checks
# find a new script without being told about it:
#
#   tests/shell_files.sh sh|zsh [file...]
#
# With no files it looks at every file git tracks or would track, and prints
# paths relative to the top of the repo. With files it prints those that are
# in the group, as given.
#
# - zsh: ends in .zsh, has a zsh shebang, or starts with `# vim:ft=zsh` or
#   `#compdef`. The last two are for files that are sourced, which have no
#   shebang.
# - sh: ends in .sh or .bash, or has an sh or bash shebang. ShellCheck reads
#   both, so they are one group; it cannot read zsh.
#
# A zsh or sh file with none of these marks is not found. Generated files
# are left out, because the app that writes them decides their format.
set -euo pipefail

generated=(
  home/dot-p10k.zsh # written by the Powerlevel10k configuration wizard
)

sh_shebang='^#!.*[/ ](ba)?sh([[:space:]]|$)'
zsh_shebang='^#!.*[/ ]zsh([[:space:]]|$)'

# Prints which group a file is in, sh or zsh, or nothing.
group_of() {
  local file=$1 first=
  case $file in
  *.zsh)
    echo zsh
    return
    ;;
  *.sh | *.bash)
    echo sh
    return
    ;;
  esac
  IFS= read -r first <"$file" || true
  if [[ $first =~ $zsh_shebang || $first == '# vim:ft=zsh'* || $first == '#compdef'* ]]; then
    echo zsh
  elif [[ $first =~ $sh_shebang ]]; then
    echo sh
  fi
}

is_generated() {
  local file=$1 g
  for g in "${generated[@]}"; do
    case $file in
    "$g" | */"$g") return 0 ;;
    esac
  done
  return 1
}

if [[ $# -lt 1 || ($1 != sh && $1 != zsh) ]]; then
  echo "usage: tests/shell_files.sh sh|zsh [file...]" >&2
  exit 2
fi
want=$1
shift

if [[ $# -eq 0 ]]; then
  cd "$(dirname "$0")/.."
  files=$(git ls-files --cached --others --exclude-standard)
else
  files=$(printf '%s\n' "$@")
fi

while IFS= read -r file; do
  # A file deleted from the working tree is still listed until it is staged.
  if [[ -z $file || ! -f $file ]] || is_generated "$file"; then
    continue
  fi
  if [[ $(group_of "$file") == "$want" ]]; then
    echo "$file"
  fi
done <<<"$files"
