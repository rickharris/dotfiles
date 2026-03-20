{ pkgs, lib, config, ... }:
let
  # TODO: change back to main repo path before merging
  dotfiles = "${config.home.homeDirectory}/src/github.com/rickharris/dotfiles/.claude/worktrees/nix-darwin-conversion";
in {
  home.stateVersion = "24.11";

  # dot — bootstrap and rebuild script, available on PATH from anywhere
  home.packages = [
    (pkgs.writeShellScriptBin "dot" (builtins.readFile ../bin/dot))
  ] ++ (with pkgs; [
    # CLI packages
    ast-grep
    # bat-extras  # TODO: verify package name — may need individual tools (batdiff, batgrep, etc.)
    deadnix
    eza
    fd
    gnused
    jq
    nixd
    ripgrep
    shfmt
    statix
    tree-sitter
    wget
  ]);

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
      NVIM_APPNAME = "astronvim";
      COREPACK_ENABLE_AUTO_PIN = "0";
    };

    initContent = lib.mkMerge [
      # Early init — must run before plugins load
      (lib.mkBefore ''
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
      '')

      # Normal init
      ''
        # Powerlevel10k theme
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        # case-insensitive, partial-word and substring completion
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

        # Source local overrides
        if [ -f ~/.zshrc.local ]; then
          . ~/.zshrc.local
        fi
      ''
    ];

    # zsh-vi-mode as a plugin — sources after initExtra
    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
  };

  # Git — replaces dot-gitconfig
  # Note: programs.git installs git itself, no home.packages entry needed
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Rick Harris";
        email = "rickharris@users.noreply.github.com";
      };
      alias = {
        st = "status";
        ci = "commit";
        co = "checkout";
        br = ''!sh -c "git checkout $(git for-each-ref --sort='-authordate:iso8601' --format=' %(authordate:relative)%09%(refname:short)' refs/heads | fzf | cut -f2)"'';
        gone = ''! "git fetch -p && for branch in $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == \"[gone]\" {sub(\"refs/heads/\", \"\", $1); print $1}'); do git branch -D $branch; done"'';
      };
      init.defaultBranch = "main";
      diff.colorMoved = "default";
      merge.conflictstyle = "zdiff3";
    };

    includes = [{ path = "~/.gitconfig.local"; }];
  };

  # Delta — git pager
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      line-numbers = true;
      navigate = true;
      syntax-theme = "ansi";
    };
  };

  # Tmux — replaces dot-tmux.conf and TPM
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    baseIndex = 1;
    mouse = true;
    keyMode = "vi";
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      pain-control
      sensible
      sessionist
      yank
      vim-tmux-navigator
    ];

    extraConfig = builtins.readFile ../home/config/tmux/status.conf;
  };

  # Bat
  programs.bat = {
    enable = true;
    config = {
      theme = "ansi";
    };
  };

  # Jujutsu
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Rick Harris";
        email = "rickharris@users.noreply.github.com";
      };
      ui = {
        default-command = "log";
      };
    };
  };

  # fzf
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Zoxide
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # GitHub CLI
  programs.gh.enable = true;

  # mise — replaces asdf and nvm
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
  };

  # Neovim — installed via Nix, config stays as Lua files
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Dotfile symlinks — link directly to repo, not the Nix store,
  # so edits take effect immediately without rebuilding.
  xdg.configFile = {
    "ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/config/ghostty";
    "lazyvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/config/lazyvim";
    "astronvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/config/astronvim";
    "zed".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/config/zed";
    "bat/themes".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/config/bat/themes";

    # Karabiner: symlink only the JSON file, not the directory.
    # Karabiner-Elements writes to this directory at runtime,
    # so the directory itself must remain writable.
    "karabiner/karabiner.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/config/karabiner/karabiner.json";
  };

  home.file = {
    ".p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/p10k.zsh";
    ".claude/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/claude/settings.json";
    ".claude/zsh".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/claude/zsh";
  };
}
