{
  config,
  lib,
  pkgs,
  ...
}: let
  shellAliases = import ./aliases.nix;
  fzfGit = import ./fzf-git.nix {};
  fzfKubectl = import ./fzf-kubectl.nix {};
  fzfTalos = import ./fzf-talos.nix {};
  fzfCilium = import ./fzf-cilium.nix {};
  dollar = "$";
  theme = {
    colors = {
      # Base colors
      bg = "#1a1b26";
      bg_dark = "#16161e";
      bg_highlight = "#292e42";
      terminal_black = "#414868";
      fg = "#c0caf5";
      fg_dark = "#a9b1d6";
      fg_gutter = "#3b4261";

      # UI elements
      dark3 = "#545c7e";
      comment = "#565f89";

      # Blues
      blue0 = "#3d59a1";
      blue = "#7aa2f7";
      cyan = "#7dcfff";
      blue1 = "#2ac3de";
      blue2 = "#0db9d7";
      blue5 = "#89ddff";
      blue6 = "#b4f9f8";
      blue7 = "#394b70";

      # Purples and pinks
      magenta = "#bb9af7";
      magenta2 = "#ff007c";
      purple = "#9d7cd8";

      # Warm colors
      orange = "#ff9e64";
      yellow = "#e0af68";

      # Greens
      green = "#9ece6a";
      green1 = "#73daca";
      green2 = "#41a6b5";
      teal = "#1abc9c";

      # Reds
      red = "#f7768e";
      red1 = "#db4b4b";
    };
  };
in {
  home = {
    sessionVariables = {
      KREW_ROOT = "${config.home.homeDirectory}/.krew";
      PATH = "${config.home.homeDirectory}/.config/emacs/bin:${config.home.homeDirectory}/.krew/bin:${config.home.homeDirectory}/bin:${config.home.homeDirectory}/.local/bin:$PATH";
      EDITOR = "nvim";
      VISUAL = "nvim";
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      TERM = "xterm-256color";
      # oh-my-zsh configuration
      ZSH = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
      ZSH_CUSTOM = "${config.home.homeDirectory}/.oh-my-zsh/custom";
      ZSH_CACHE_DIR = "${config.home.homeDirectory}/.cache/oh-my-zsh";
      # fzf configuration
      FZF_BASE = "${pkgs.fzf}/share/fzf";
    };

    packages = with pkgs; [
      oh-my-zsh
      zsh-autosuggestions
      zsh-syntax-highlighting
      zsh-history-substring-search
    ];
  };

  programs = {
    # yazi, lazygit, fzf, and bat have been moved to their own modules in /nix/modules/home-manager/

    zsh = {
      enable = true;
      inherit shellAliases;
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
        plugins = [
          "git"
          "sudo"
          "direnv"
          "extract"
          "colored-man-pages"
          "kubectl"
          "docker"
          "docker-compose"
          "macos"
          "jsontools"
        ];
      };

      initContent = ''
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

        # Initialize zoxide with cd as the command
        eval "$(zoxide init zsh --cmd cd)"

        # Initialize direnv
        eval "$(direnv hook zsh)"

        # Set GPG_TTY for Git commit signing
        export GPG_TTY=$(tty)

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
            export|unset) fzf --preview 'eval "echo ${dollar}{}"' "$@" ;;
            # DNS lookup preview for SSH hosts
            ssh)          fzf --preview 'dig {}'                   "$@" ;;
            # Default preview using the global preview command
            *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
          esac
        }

        # Git FZF Integration (imported from fzf-git.nix)
        ${fzfGit}

        # Kubectl FZF Integration (imported from fzf-kubectl.nix)
        ${fzfKubectl}

        # Talos FZF Integration (imported from fzf-talos.nix)
        ${fzfTalos}

        # Cilium FZF Integration (imported from fzf-cilium.nix)
        ${fzfCilium}

        # Source oh-my-zsh first (before Starship)
        if [ -f "$ZSH/oh-my-zsh.sh" ]; then
          source "$ZSH/oh-my-zsh.sh"
        else
          echo "Warning: oh-my-zsh.sh not found at $ZSH/oh-my-zsh.sh"
        fi

        # Initialize Starship prompt (must be after oh-my-zsh)
        eval "$(starship init zsh)"

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
