# Shared FZF configuration: declarative options + custom shell functions
{...}: {
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = ["--height 50%" "-1" "--layout=reverse" "--multi"];
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetOptions = [
      "--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'"
    ];
    changeDirWidgetCommand = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
    changeDirWidgetOptions = ["--preview 'eza --tree --color=always {} | head -200'"];
    tmux.enableShellIntegration = true;
  };

  programs.zsh.initContent = ''
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
        *)            fzf --preview "if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi" "$@" ;;
      esac
    }
  '';
}
