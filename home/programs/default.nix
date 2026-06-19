_: {
  imports = [
    ./theme

    ./security/ssh.nix

    ./shells/zsh/aliases.nix
    ./shells/bash
    ./shells/zsh
    ./shells/starship

    ./development/git
    ./development/direnv

    ./editors/neovim
    ./editors/emacs
    ./editors/neovide

    ./terminals/kitty
    ./terminals/sesh
    ./terminals/tmux
    #./terminals/alacritty
    #./terminals/ghostty
    #./terminals/wezterm

    ./utilities/btop
    ./utilities/claude
    ./utilities/yazi
    ./utilities/aerospace
  ];
}
