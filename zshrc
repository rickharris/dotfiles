export EDITOR="vi"
export GOPATH=$HOME
export PATH="$GOPATH/bin:$PATH"
export PURE_PROMPT_SYMBOL="∴"

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
zplug "lukechilds/zsh-nvm"

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

if [ -f ~/.zshrc.local ]; then
  . ~/.zshrc.local
fi
