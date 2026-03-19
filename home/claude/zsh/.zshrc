# Minimal zsh config for Claude Code shell sessions.
# Intentionally omits: powerlevel10k, zoxide, oh-my-zsh, plugins, etc.

# Basic PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Add Homebrew if present
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Unset prompt customizations that can emit escape sequences
unset PROMPT RPROMPT PS1 PS2
