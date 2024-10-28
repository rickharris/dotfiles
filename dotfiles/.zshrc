# Enable Powerlevel10k instant prompt. Should stay close to the top of
# ~/.zshrc. Initialization code that may require console input (password
# prompts, [y/n] confirmations, etc.) must go above this block; everything else
# may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Use vi mode
bindkey -v
# And also a beam as the cursor
echo -ne '\e[5 q'

# Callback for vim mode change
function zle-keymap-select () {
  if [ $KEYMAP = vicmd ]; then
    # Set block cursor
    echo -ne '\e[1 q'
  else
    # Set beam cursor
    echo -ne '\e[5 q'
  fi
}

# Bind the callback
zle -N zle-keymap-select

# Reduce latency when pressing <Esc>
export KEYTIMEOUT=1

source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

FPATH=$HOME/.local/share/zsh/site-functions:$FPATH
autoload -Uz compinit
compinit

export PATH="$PATH:$HOME/.local/bin"
export EDITOR="nvim"
alias vi="$EDITOR"
alias vim="$EDITOR"
alias ls="eza --icons --git"
alias cd="z"

export HISTSIZE=50000
export SAVEHIST=10000
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

# case-insensitive,partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

export ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY=latest_installed
export ASDF_NODEJS_AUTO_ENABLE_COREPACK=true
. /opt/homebrew/opt/asdf/libexec/asdf.sh

eval "$(zoxide init zsh)"

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh
