{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./fzf-git.nix
    ./fzf-kubectl.nix
    ./fzf-cilium.nix
    ./fzf-claude.nix
    ./direnv-hook.nix
  ];

  home = {
    # Ripgrep configuration file
    file.".ripgreprc".text = ''
      --smart-case
      --hidden
      --glob=!.git/*
      --glob=!node_modules/*
      --glob=!.direnv/*
      --glob=!target/*
      --glob=!dist/*
      --glob=!.next/*
      --glob=!__pycache__/*
      --glob=!.venv/*
      --max-columns=200
      --max-columns-preview
    '';

    sessionPath = [
      "${config.home.homeDirectory}/.config/emacs/bin"
      "${config.home.homeDirectory}/.krew/bin"
      "${config.home.homeDirectory}/bin"
      "${config.home.homeDirectory}/.local/bin"
    ];

    sessionVariables = {
      KREW_ROOT = "${config.home.homeDirectory}/.krew";
      EDITOR = "nvim";
      VISUAL = "nvim";
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      TERM = "xterm-256color";
      # oh-my-zsh configuration
      ZSH = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
      ZSH_CACHE_DIR = "${config.home.homeDirectory}/.cache/oh-my-zsh";
      # fzf configuration
      FZF_BASE = "${pkgs.fzf}/share/fzf";
    };

    packages = with pkgs; [
      oh-my-zsh
    ];
  };

  programs = {
    # yazi, lazygit, fzf, and bat are configured in home/programs/utilities/

    zsh = {
      enable = true;
      enableCompletion = true;

      # Enable native plugins
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      historySubstringSearch.enable = true;

      history = {
        size = lib.mkForce 50000;
        save = lib.mkForce 50000;
        path = "${config.home.homeDirectory}/.zsh_history";
        ignoreDups = true;
        share = true;
        extended = true;
      };

      oh-my-zsh = {
        enable = true;
        package = pkgs.oh-my-zsh;
        theme = ""; # Disabled theme to use Starship instead
        plugins =
          [
            "sudo"
            "extract"
            "colored-man-pages"
            "jsontools"
          ]
          ++ lib.optionals pkgs.stdenv.isDarwin ["macos"];
      };

      initContent = ''
        # Raise open file limit (macOS default 256 is too low for nix flake update)
        ulimit -n 10240

        # Performance optimizations
        export DISABLE_AUTO_UPDATE="true"
        export DISABLE_MAGIC_FUNCTIONS="true"
        export ZSH_AUTOSUGGEST_USE_ASYNC=1
        export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
        export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

        # Set a fixed path for the completion dump
        export ZSH_COMPDUMP="$ZSH_CACHE_DIR/.zcompdump"

        # Ensure cache directory exists
        if [[ ! -d "$ZSH_CACHE_DIR" ]]; then
          mkdir -p "$ZSH_CACHE_DIR"
        fi

        # Optimize completion loading - only rebuild cache once per day
        autoload -Uz compinit
        if [[ -n $ZSH_COMPDUMP(#qN.mh+24) ]]; then
          compinit -d "$ZSH_COMPDUMP"
        else
          compinit -C -d "$ZSH_COMPDUMP"
        fi

        # Initialize zoxide (use z/zi commands, don't override cd)
        eval "$(zoxide init zsh)"

        # Set GPG_TTY for Git commit signing
        export GPG_TTY=$(tty)

        # Ripgrep configuration (smart-case, ignore common dirs)
        export RIPGREP_CONFIG_PATH="${config.home.homeDirectory}/.ripgreprc"

        # FZF configuration
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_DEFAULT_OPTS="--height 50% -1 --layout=reverse --multi"

        # Use fd for FZF commands
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

        # Preview configuration
        show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
        export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
        export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

        # Basic path completion functions for FZF
        # Used when you press tab to complete paths
        _fzf_compgen_path() {
          # Generate completions for all file types, including hidden ones
          # Excludes .git directory to avoid noise
          fd --hidden --exclude .git . "$1"
        }

        # Directory-specific completion function
        # Used when completing directory paths specifically
        _fzf_compgen_dir() {
          # Only show directories, including hidden ones
          # Excludes .git directory to keep results clean
          fd --type=d --hidden --exclude .git . "$1"
        }

        # Advanced completion behavior customization
        # This function determines how FZF preview works for different commands
        _fzf_comprun() {
          local command=$1
          shift

          case "$command" in
            # Directory preview with tree view
            cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
            # Preview environment variables with their values expanded
            export|unset) fzf --preview 'eval "echo ''${}"' "$@" ;;
            # DNS lookup preview for SSH hosts
            ssh)          fzf --preview 'dig {}'                   "$@" ;;
            # Default preview using the global preview command
            *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
          esac
        }

        # Source oh-my-zsh first (before Starship)
        if [ -f "$ZSH/oh-my-zsh.sh" ]; then
          source "$ZSH/oh-my-zsh.sh"
        else
          echo "Warning: oh-my-zsh.sh not found at $ZSH/oh-my-zsh.sh"
        fi

        # Basic configurations
        zstyle ':completion:*' matcher-list "" 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
        WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

        # Fix for zle warnings
        zmodload zsh/zle
        zmodload zsh/zpty
        zmodload zsh/complete

        # Advanced ZSH options
        setopt AUTO_CD
        setopt AUTO_PUSHD
        setopt PUSHD_IGNORE_DUPS
        setopt PUSHD_MINUS
        setopt EXTENDED_HISTORY
        setopt HIST_EXPIRE_DUPS_FIRST
        setopt HIST_IGNORE_DUPS
        setopt HIST_IGNORE_SPACE
        setopt HIST_VERIFY
        setopt SHARE_HISTORY
        setopt INTERACTIVE_COMMENTS
        setopt COMPLETE_IN_WORD
        setopt ALWAYS_TO_END
        setopt PATH_DIRS
        setopt AUTO_MENU
        setopt AUTO_LIST
        setopt AUTO_PARAM_SLASH
        setopt NO_BEEP
      '';

      profileExtra = ''
        if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
          . $HOME/.nix-profile/etc/profile.d/nix.sh
        fi
      '';
    };
  };
}
