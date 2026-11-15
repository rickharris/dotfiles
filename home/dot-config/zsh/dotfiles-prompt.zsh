# vim:ft=zsh
#
# A Powerlevel10k segment that shows how far behind origin/main the dotfiles
# are, as "dot ⇣3". Sourced by ~/.zshrc after ~/.p10k.zsh.
#
# It lives here rather than in ~/.p10k.zsh so that `p10k configure`, which
# rewrites that file, does not remove it. The file name must not start with
# "dot-": stow would link it as a dotfile.
#
# The segment never runs git. It shows the count that `dot update --check`
# last wrote to a cache file, and runs that check in the background when the
# count is out of date.

zmodload -F zsh/stat b:zstat
zmodload zsh/datetime

# The dotfiles repo: four directories up from this file, once the symlink it
# is sourced through is resolved.
typeset -g _dot_prompt_repo=${${(%):-%x}:A:h:h:h:h}

# When this shell last started a check, and where the checkout was then.
typeset -g _dot_prompt_launched_at=0 _dot_prompt_launched_head=

# Sets REPLY to when the checkout last moved: a commit, a pull, a switch of
# branch. git appends to this file each time. Empty if there is no such file.
function _dot_prompt_head_mtime() {
  local -a mtime
  REPLY=
  if zstat -A mtime +mtime -- "$_dot_prompt_repo/.git/logs/HEAD" 2>/dev/null; then
    REPLY=$mtime[1]
  fi
}

# Succeeds when the cached count is out of date: the cache file is missing,
# was written over an hour ago, or is older than the last time the checkout
# moved. `dot update --check` touches the file as soon as it starts, so a
# check that is still running, or one that failed, counts as up to date.
function _dot_prompt_stale() {
  local -a cache
  local REPLY
  if ! zstat -A cache +mtime -- "${XDG_CACHE_HOME:-$HOME/.cache}/dot/behind" 2>/dev/null; then
    return 0
  fi
  if ((EPOCHSECONDS - cache[1] > 3600)); then
    return 0
  fi
  _dot_prompt_head_mtime
  if [[ -z $REPLY ]]; then
    return 1
  fi
  ((REPLY > cache[1]))
}

# Succeeds when a check should be started now, and notes that one was. A
# stale count is not enough: if the check cannot write the cache file, or dot
# is not on PATH, the count stays stale, and that must not start a check on
# every prompt. So this shell starts another only after an hour, or once the
# checkout has moved again.
function _dot_prompt_should_check() {
  local REPLY
  if ! _dot_prompt_stale; then
    return 1
  fi
  _dot_prompt_head_mtime
  if ((EPOCHSECONDS - _dot_prompt_launched_at <= 3600)) &&
    [[ $REPLY == "$_dot_prompt_launched_head" ]]; then
    return 1
  fi
  _dot_prompt_launched_at=$EPOCHSECONDS
  _dot_prompt_launched_head=$REPLY
}

# Draws the segment when the cache file holds a count above zero. An empty
# file means the count is not known, which shows nothing.
function _dot_prompt_show() {
  local file=${XDG_CACHE_HOME:-$HOME/.cache}/dot/behind count
  if [[ ! -r $file ]]; then
    return 0
  fi
  count=$(<"$file")
  # Digits only: nothing is left once the digits are removed.
  if [[ -n $count && -z ${count//[0-9]/} ]] && ((count > 0)); then
    p10k segment -f 4 -t "dot ⇣$count"
  fi
}

# Powerlevel10k calls this before every prompt.
function prompt_dotfiles() {
  if _dot_prompt_should_check; then
    dot update --check </dev/null &>/dev/null &|
  fi
  _dot_prompt_show
}

# The instant prompt is drawn before zsh has finished starting, so it only
# shows what is cached.
function instant_prompt_dotfiles() {
  _dot_prompt_show
}

# First on the right, unless it is already there because this file was
# sourced before. The list is unset when there is no ~/.p10k.zsh.
if ((${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[(I)dotfiles]:-0} == 0)); then
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(dotfiles $POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS)
fi
