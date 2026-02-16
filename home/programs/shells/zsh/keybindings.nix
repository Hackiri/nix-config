# Pure vim mode keybindings with cursor shape switching and custom widgets
{lib, ...}: {
  programs.zsh.initContent = lib.mkBefore ''
    # Enable vim mode
    bindkey -v
    export KEYTIMEOUT=1

    # Cursor shape switching between vim modes
    # Block cursor = normal mode, beam cursor = insert mode
    zle-keymap-select() {
      case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block cursor
        viins|main) echo -ne '\e[5 q';;  # beam cursor
      esac
    }
    zle -N zle-keymap-select

    # Start with beam cursor (insert mode is default)
    zle-line-init() {
      echo -ne '\e[5 q'
    }
    zle -N zle-line-init

    # Prefix-based history search with arrow keys
    # Type "git" then press Up to cycle through commands starting with "git"
    autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
    zle -N up-line-or-beginning-search
    zle -N down-line-or-beginning-search
    bindkey '^[[A' up-line-or-beginning-search   # Up arrow
    bindkey '^[[B' down-line-or-beginning-search  # Down arrow
    bindkey -M vicmd 'k' up-line-or-beginning-search
    bindkey -M vicmd 'j' down-line-or-beginning-search

    # Accept and hold — run command but keep it on the line for re-execution
    bindkey '^\' accept-and-hold

    # Edit command in $EDITOR
    autoload -Uz edit-command-line
    zle -N edit-command-line
    bindkey '^x^e' edit-command-line
    bindkey -M vicmd 'v' edit-command-line

    # Sudo toggle widget (replaces oh-my-zsh sudo plugin)
    # Double-tap ESC to add/remove sudo prefix
    _sudo_toggle() {
      if [[ "$BUFFER" == sudo\ * ]]; then
        BUFFER="''${BUFFER#sudo }"
        (( CURSOR -= 5 ))
      else
        BUFFER="sudo $BUFFER"
        (( CURSOR += 5 ))
      fi
    }
    zle -N _sudo_toggle
    bindkey '\e\e' _sudo_toggle

    # Fix backspace in vim insert mode
    bindkey '^?' backward-delete-char
    bindkey '^H' backward-delete-char

    # Fix delete key
    bindkey '^[[3~' delete-char
  '';
}
