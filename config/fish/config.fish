set -U EDITOR nvim
set -U fish_user_paths $fish_user_paths $HOME/bin

if test (which go)
  export GOPATH=$HOME
end

alias git-clean="git branch --merged master | grep -v \"\* master\" | xargs -n 1 git branch -d"
alias mux="tmuxinator"
set pure_symbol_prompt "∴"
