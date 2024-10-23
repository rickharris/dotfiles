#!/usr/bin/env sh
set -e

# Try to load homebrew in case it has been installed already but the script
# failed and needs to be re-run. This keeps us from re-installing homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install hombrew first, which will download also download Command Line Tools
# for Xcode.
if test ! $(which brew); then
  echo -e "\nInstalling Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

  if [[ ! -f $HOME/.zprofile ]]; then
    touch $HOME/.zprofile
  fi
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>/Users/rick/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
  brew completions link
fi

dir=$HOME/src/github.com/rickharris/dotfiles
if [ ! -d $dir ]; then
  echo -e "\nDownloading dotfiles repo…"
  git clone https://github.com/rickharris/dotfiles.git $dir
fi
cd $dir

if [[ ! -f $HOME/.ssh/id_ed25519 ]]; then
  echo -e "\nCreating an ssh key…"
  ssh-keygen -t ed25519
  ssh-add -K $HOME/.ssh/id_ed25519
fi

if [[ ! -d $HOME/.keyboard ]]; then
  echo -e "\nInstalling keyboard customizations…"
  git clone https://github.com/jasonrudolph/keyboard.git ~/.keyboard
  pushd ~/.keyboard
  ./script/setup
  popd
fi

brew bundle check --no-upgrade || brew bundle --no-lock --no-upgrade

stow --verbose --target=$HOME --restow dotfiles

defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$HOME/.config/iterm2"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

. /opt/homebrew/opt/asdf/libexec/asdf.sh
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git >/dev/null
asdf install nodejs latest
asdf global nodejs latest
corepack enable
asdf reshim nodejs
