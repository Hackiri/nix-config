# Minimal profile - essential cross-platform tools and configurations
# This profile provides the foundation that all other profiles inherit from.
# It includes only the most essential tools that should be available everywhere.
{
  pkgs,
  username,
  ...
}: {
  imports = [
    # Packages: Core CLI tools (bat, eza, fd, fzf, ripgrep, etc.)
    ../../packages/cli-essentials.nix

    # Packages: Network essentials (curl, wget, cachix)
    ../../packages/network.nix

    # Programs: Shell configuration and enhancements
    ../../programs/shells

    # Programs: Essential system monitoring utilities
    ../../programs/utilities/btop
  ];

  # Common home-manager configuration (replaces home/shared/base.nix)
  home = {
    inherit username;
    stateVersion = "25.05";

    # Essential cross-platform packages (beyond imported package files)
    packages = with pkgs; [
      #--------------------------------------------------
      # System Utilities
      #--------------------------------------------------
      vim # Basic text editor (for minimal systems)
      neofetch # System information tool
      htop # Interactive process viewer

      #--------------------------------------------------
      # File Processing & Archives
      #--------------------------------------------------
      unzip # Extract ZIP archives
      zip # Create ZIP archives
      gzip # GNU compression utility
    ];
  };

  # Essential programs that work everywhere
  programs = {
    home-manager.enable = true;

    # Direnv for automatic environment loading
    direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    # Git basic configuration (can be extended in development profile)
    git = {
      enable = true;
      # Basic settings that apply everywhere - specific config in development profile
    };
  };
}
