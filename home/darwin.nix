# Home Manager config for macOS
{
  config,
  pkgs,
  ...
}: {
  # macOS-specific packages
  home.packages = with pkgs; [
    # Add macOS-specific packages here
    mkalias # Tool for creating macOS aliases
    pam-reattach # Enables Touch ID support in tmux
    cachix # Nix binary cache client

    # Python packages moved from common.nix
    python312 # Python programming language
    python312Packages.pip # Python package manager (needed for Mason)
    python3Packages.pygments # Syntax highlighting (pygmentize)
  ];
}
