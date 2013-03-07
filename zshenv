export PATH="/usr/local/bin:$PATH"

# Local machine-specific configuration
if [ -f ~/.zshenv_local ]; then
  . ~/.zshenv_local
fi
