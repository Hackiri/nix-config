# Home Manager config for macOS
{
  config,
  pkgs,
  ...
}: {
  # Import macOS-specific modules
  imports = [
    ./programs/utilities/aerospace
  ];

  # macOS-specific packages that don't have dedicated modules
  home.packages = with pkgs; [
    # macOS-specific utilities
    mkalias # Tool for creating macOS aliases
    pam-reattach # Enables Touch ID support in tmux
    cachix # Nix binary cache client
  ];
}
