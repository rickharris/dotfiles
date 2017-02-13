export EDITOR="vi"
export PURE_PROMPT_SYMBOL="∴"
export PATH="$PATH:$HOME/bin"

if test $(which yarn)
then
  export PATH="$PATH:`yarn global bin`"
fi

if test $(which go)
then
  export GOPATH=$HOME
fi

alias vi="nvim"
alias vim="nvim"

if [[ ! -d ~/.zplug ]]; then
  curl -sL zplug.sh/installer | zsh
fi

source ~/.zplug/init.zsh

zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-completions"
zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:"pure.zsh", from:github, as:theme
zplug "lib/history", from:oh-my-zsh
zplug "plugins/z", from:oh-my-zsh
zplug "tmuxinator/tmuxinator", from:github, use:"completion/tmuxinator.zsh"

# Install packages that have not been installed yet
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    else
        echo
    fi
fi

zplug load

# case-insensitive,partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

if [ -f ~/.zshrc.local ]; then
  . ~/.zshrc.local
fi
