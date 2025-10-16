{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  shellAliases = import ./aliases.nix;
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

                # Git Integration Helper Functions

                # Check if current directory is a git repository
                is_in_git_repo() {
                  git rev-parse HEAD > /dev/null 2>&1
                }

                # Standard FZF configuration for git operations
                # Creates a dropdown with preview toggle (ctrl-/)
                fzf-down() {
                  fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
                }

                # Git File Status Browser (^g^f)
                # Shows modified/untracked files with diff preview
                _gf() {
                  is_in_git_repo || return
                  git -c color.status=always status --short |
                  fzf-down -m --ansi --nth 2..,.. \
                    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1})' |
                  cut -c4- | sed 's/.* -> //'
                }

                # Git Branch Browser (^g^b)
                # Shows local and remote branches with commit history preview
                _gb() {
                  is_in_git_repo || return
                  git branch -a --color=always | grep -v '/HEAD\s' | sort |
                  fzf-down --ansi --multi --tac --preview-window right:70% \
                    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
                  sed 's/^..//' | cut -d' ' -f1 |
                  sed 's#^remotes/##'
                }

                # Git Tag Browser (^g^t)
                # Lists all tags with their details in preview
                _gt() {
                  is_in_git_repo || return
                  git tag --sort -version:refname |
                  fzf-down --multi --preview-window right:70% \
                    --preview 'git show --color=always {}'
                }

                # Git History Browser (^g^h)
                # Interactive commit history with diff preview
                # Use ctrl-s to toggle sort order
                _gh() {
                  is_in_git_repo || return
                  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
                  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
                    --header 'Press CTRL-S to toggle sort' \
                    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' |
                  grep -o "[a-f0-9]\{7,\}"
                }

                # Git Remote Browser (^g^r)
                # Lists remotes with their commit history
                _gr() {
                  is_in_git_repo || return
                  git remote -v | awk '{print $1 "\t" $2}' | uniq |
                  fzf-down --tac \
                    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1}' |
                  cut -d$'\t' -f1
                }

                # Git Stash Browser (^g^s)
                # Browse and view stashed changes
                _gs() {
                  is_in_git_repo || return
                  git stash list | fzf-down --reverse -d: --preview 'git show --color=always {1}' |
                  cut -d: -f1
                }

                # Helper function to join multiple selected items
                # Used when multiple selections are made in FZF
                join-lines() {
                  local item
                  while read item; do
                    echo -n "''${(q)item} "
                  done
                }

                # Function to bind all git helper functions to keyboard shortcuts
                # Creates widgets and binds them to ctrl-g + ctrl-[key] combinations
                bind-git-helper() {
                  local c
                  for c in $@; do
                    # Create widget function that calls the corresponding _g[key] function
                    eval "fzf-g$c-widget() { local result=\$(_g$c | join-lines); zle reset-prompt; LBUFFER+=\$result }"
                    # Register the widget with ZLE (Zsh Line Editor)
                    eval "zle -N fzf-g$c-widget"
                    # Bind widget to ctrl-g + ctrl-[key]
                    eval "bindkey '^g^$c' fzf-g$c-widget"
                  done
                }

                # Enhanced Git Status Browser (^g^s)
                # Interactive status view with detailed file information and actions
                _gst() {
                  is_in_git_repo || return
                  git status --short | fzf-down --ansi \
                    --preview 'git diff --color=always {2}' \
                    --header 'Press CTRL-A to add/unstage, CTRL-C to commit' \
                    --bind 'ctrl-a:execute(git add {2} || git restore --staged {2})' \
                    --bind 'ctrl-c:execute(git commit)' \
                    --preview-window right:70%
                }

                # Interactive Git Add (^g^a)
                # Multi-select files to stage with preview
                _ga() {
                  is_in_git_repo || return
                  # Show both unstaged and untracked files
                  git ls-files --modified --others --exclude-standard |
                  fzf-down --ansi --multi \
                    --preview 'git diff --color=always {} || bat --color=always {}' \
                    --header 'Select files to stage (TAB to multi-select)' \
                    --bind 'enter:execute(git add {})' \
                    --preview-window right:70%
                }

                # Detailed Git Commit Browser (^g^c)
                # Interactive commit creation with template and preview
                _gc() {
                  is_in_git_repo || return
                  # Show staged files with their diffs
                  local staged_files="''$(git diff --cached --name-only)"
                  if [ -z "''$staged_files" ]; then
                    echo "No files staged for commit"
                    return 1
                  fi

                  # Create a temporary file for the commit message
                  local temp_msg="''$(mktemp)"
                  echo "# Write your commit message (first line is the subject)
        #
        # Changes to be committed:
        #" > "''$temp_msg"
                  git diff --cached --name-status >> "''$temp_msg"

                  # Open commit message in preferred editor with preview
                  "''$EDITOR" "''$temp_msg" && {
                    # Remove comments and empty lines
                    local commit_msg="''$(grep -v '^#' "''$temp_msg" | sed '/^$/d')"
                    if [ -n "''$commit_msg" ]; then
                      git commit -F "''$temp_msg"
                    fi
                  }
                  rm "''$temp_msg"
                }

                # Bind new git helper functions
                bind-git-helper f b t r h s st a c
                unset -f bind-git-helper

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
