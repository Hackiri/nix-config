# Shared FZF configuration: env vars, fzf-down, compgen, comprun
{config, ...}: {
  home.sessionVariables = {
    FZF_BASE = "${config.home.homeDirectory}/.nix-profile/share/fzf";
  };

  programs.zsh.initContent = ''
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

    # Shared FZF dropdown function used by all integration modules
    # (fzf-git, fzf-kubectl, fzf-cilium, fzf-claude)
    fzf-down() {
      fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
    }

    # Path completion for FZF tab
    _fzf_compgen_path() {
      fd --hidden --exclude .git . "$1"
    }

    # Directory completion for FZF tab
    _fzf_compgen_dir() {
      fd --type=d --hidden --exclude .git . "$1"
    }

    # Per-command preview behavior
    _fzf_comprun() {
      local command=$1
      shift

      case "$command" in
        cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
        export|unset) fzf --preview 'eval "echo ''${}"' "$@" ;;
        ssh)          fzf --preview 'dig {}'                   "$@" ;;
        *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
      esac
    }
  '';
}
