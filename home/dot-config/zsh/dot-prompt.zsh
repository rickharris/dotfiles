# vim:ft=zsh
#
# A Powerlevel10k segment that shows how far behind origin/main the dotfiles
# are, as "dot ⇣3". Sourced by ~/.zshrc after ~/.p10k.zsh.
#
# It lives here rather than in ~/.p10k.zsh so that `p10k configure`, which
# rewrites that file, does not remove it.
#
# The segment never talks to git. It shows the count that `dot update --check`
# last wrote to a cache file, and runs that check in the background when the
# file is more than an hour old.

zmodload -F zsh/stat b:zstat
zmodload zsh/datetime

# Succeeds when the cache file is missing or was last written over an hour
# ago. `dot update --check` touches the file as soon as it starts, so a check
# that is still running, or one that failed, counts as fresh.
function _dot_prompt_stale() {
  local -a mtime
  if ! zstat -A mtime +mtime -- "${XDG_CACHE_HOME:-$HOME/.cache}/dot/behind" 2>/dev/null; then
    return 0
  fi
  ((EPOCHSECONDS - mtime[1] > 3600))
}

# Draws the segment when the cache file holds a count above zero. An empty
# file means the count is not known, which shows nothing.
function _dot_prompt_show() {
  local file=${XDG_CACHE_HOME:-$HOME/.cache}/dot/behind count
  if [[ ! -r $file ]]; then
    return 0
  fi
  count=$(<"$file")
  if [[ $count =~ '^[0-9]+$' ]] && ((count > 0)); then
    p10k segment -f 4 -t "dot ⇣$count"
  fi
}

# Powerlevel10k calls this before every prompt.
function prompt_dotfiles() {
  if _dot_prompt_stale; then
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
# sourced before.
if ((! ${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[(I)dotfiles]})); then
  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(dotfiles $POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS)
fi
