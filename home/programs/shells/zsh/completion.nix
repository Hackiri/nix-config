# Completion system with fzf-tab and compinit optimization
{pkgs, ...}: {
  programs.zsh = {
    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];

    initContent = ''
      # Ensure cache directory exists
      ZSH_CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
      if [[ ! -d "$ZSH_CACHE_DIR" ]]; then
        mkdir -p "$ZSH_CACHE_DIR"
      fi

      # Optimize completion loading — only rebuild cache once per day
      ZSH_COMPDUMP="$ZSH_CACHE_DIR/.zcompdump"
      autoload -Uz compinit
      if [[ -n $ZSH_COMPDUMP(#qN.mh+24) ]]; then
        compinit -d "$ZSH_COMPDUMP"
      else
        compinit -C -d "$ZSH_COMPDUMP"
      fi

      # Completion styling
      zstyle ':completion:*' matcher-list "" 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*' menu select
      zstyle ':completion:*' special-dirs true
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':completion:*' group-name ""

      # fzf-tab configuration
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --color=always --level=1 $realpath'
      zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza --tree --color=always --level=1 $realpath'
      zstyle ':fzf-tab:complete:cat:*' fzf-preview 'bat --color=always --line-range :500 $realpath'
      zstyle ':fzf-tab:complete:bat:*' fzf-preview 'bat --color=always --line-range :500 $realpath'
      zstyle ':fzf-tab:complete:vim:*' fzf-preview 'bat --color=always --line-range :500 $realpath'
      zstyle ':fzf-tab:complete:nvim:*' fzf-preview 'bat --color=always --line-range :500 $realpath'
      zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps -p $word -o pid,user,%cpu,%mem,start,command'
      zstyle ':fzf-tab:complete:kill:argument-rest' fzf-flags '--preview-window=down:3:wrap'
      zstyle ':fzf-tab:*' fzf-flags '--height=50%'
      zstyle ':fzf-tab:*' switch-group '<' '>'
    '';
  };
}
