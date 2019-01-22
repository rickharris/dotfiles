set -x EDITOR nvim
set -x fish_user_paths $fish_user_paths $HOME/bin

if test (which go)
  set -x GOPATH $HOME
end

alias git-clean="git branch --merged master | grep -v \"\* master\" | xargs -n 1 git branch -d"
alias mux="tmuxinator"
set pure_symbol_prompt "∴"
set pure_color_git_branch $pure_color_normal
set pure_color_git_dirty $pure_color_normal
