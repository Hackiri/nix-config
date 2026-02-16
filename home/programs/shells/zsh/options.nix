# Shell options, zmodload, and modern zsh features
_: {
  programs.zsh.initContent = ''
    # Zsh modules
    zmodload zsh/zle
    zmodload zsh/zpty
    zmodload zsh/complete

    # Deduplicate PATH and FPATH
    typeset -U path fpath

    # Bulk rename utility
    autoload -Uz zmv

    # Named directories
    hash -d nix=~/nix-config
    hash -d dl=~/Downloads
    hash -d docs=~/Documents

    # Directory behavior
    setopt AUTO_CD
    setopt AUTO_PUSHD
    setopt PUSHD_IGNORE_DUPS
    setopt PUSHD_MINUS

    # History
    setopt EXTENDED_HISTORY
    setopt HIST_EXPIRE_DUPS_FIRST
    setopt HIST_IGNORE_DUPS
    setopt HIST_IGNORE_SPACE
    setopt HIST_VERIFY
    setopt SHARE_HISTORY

    # Completion
    setopt COMPLETE_IN_WORD
    setopt ALWAYS_TO_END
    setopt AUTO_MENU
    setopt AUTO_LIST
    setopt AUTO_PARAM_SLASH

    # Globbing
    setopt EXTENDED_GLOB
    setopt GLOB_DOTS

    # Misc
    setopt PATH_DIRS
    setopt INTERACTIVE_COMMENTS
    setopt COMBINING_CHARS
    setopt NO_FLOW_CONTROL
    setopt NO_BEEP
  '';
}
