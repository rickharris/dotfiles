#!/usr/bin/env sh
set -e

echo "
Before running this script, enable Full Disk Access for your terminal.

https://support.apple.com/guide/mac-help/change-privacy-security-settings-on-mac-mchl211c911f/mac
"

# Many things taken from https://mths.be/macos

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Fast key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Hide Dock
defaults write com.apple.dock autohide -bool true

# No recents in Dock
defaults write com.apple.dock show-recents -bool false

# Finder defaults to column view
defaults write com.apple.finder "FXPreferredViewStyle" -string "clmv" && killall Finder

# Safari Developer Menu
defaults write com.apple.Safari IncludeDevelopMenu -bool true

# Ask for location only once per website
# 0 = deny everything
# 1 = ask once per day
# 2 = ask once
defaults write com.apple.Safari SafariGeolocationPermissionPolicy -int 2

# Privacy: don’t send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Press Tab to highlight each item on a web page
defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

# Disable AutoFill
# defaults write com.apple.Safari AutoFillFromAddressBook -bool false
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillCreditCardData -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

# Show status bar
defaults write com.apple.Safari ShowStatusBar -bool true
defaults write com.apple.Safari ShowOverlayStatusBar -bool true
defaults write com.apple.Safari ShowStatusBarInFullScreen -bool true

# Configure DuckDuckGo as main search engine
defaults write com.apple.Safari SearchProviderIdentifier -string "com.duckduckgo"
defaults write NSGlobalDomain NSProviderIdentifier -string "com.duckduckgo"

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

defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$PWD/iterm2"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

. /opt/homebrew/opt/asdf/libexec/asdf.sh
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git >/dev/null
asdf install nodejs latest
asdf global nodejs latest
corepack enable
asdf reshim nodejs
