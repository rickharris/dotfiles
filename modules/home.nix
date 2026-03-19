{ pkgs, ... }: {
  home.stateVersion = "24.11";

  # CLI packages — replaces brew formulae without dedicated home-manager modules
  home.packages = with pkgs; [
    ast-grep
    eza
    fd
    gnused
    jq
    ripgrep
    shfmt
    tree-sitter
    wget
  ];

  # Zsh — replaces dot-zshrc
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    enableCompletion = true;

    history = {
      size = 50000;
      save = 10000;
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      extended = true;
    };

    shellAliases = {
      vi = "$EDITOR";
      vim = "$EDITOR";
      ls = "eza --icons --git";
      cd = "z";
    };

    sessionVariables = {
      EDITOR = "nvim";
      NVIM_APPNAME = "astronvim";
      COREPACK_ENABLE_AUTO_PIN = "0";
    };

    # zvm_before_init MUST be declared before zsh-vi-mode loads.
    # initExtraFirst runs before plugins are sourced.
    initExtraFirst = ''
      # Powerlevel10k instant prompt — must be near the top
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # vi mode keybindings for history substring search
      # Must be declared before zsh-vi-mode loads
      function zvm_before_init() {
        zvm_bindkey viins '^[[A' history-substring-search-up
        zvm_bindkey viins '^[[B' history-substring-search-down
        zvm_bindkey vicmd '^[[A' history-substring-search-up
        zvm_bindkey vicmd '^[[B' history-substring-search-down
      }
    '';

    initExtra = ''
      # Powerlevel10k theme
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # case-insensitive, partial-word and substring completion
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

      # Source local overrides
      if [ -f ~/.zshrc.local ]; then
        . ~/.zshrc.local
      fi
    '';

    # zsh-vi-mode as a plugin — sources after initExtra
    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
  };
}
