# Minimal profile - essential cross-platform tools and configurations
# This profile provides the foundation that all other profiles inherit from.
# It includes only the most essential tools that should be available everywhere.
{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  imports = [
    # Basic shell enhancements
    ../programs/shells/default.nix

    # Essential utilities
    ../programs/utilities/btop
  ];

  # Common home-manager configuration (replaces home/shared/base.nix)
  home = {
    inherit username;
    stateVersion = "25.05";

    # Essential cross-platform packages
    packages = with pkgs; [
      #--------------------------------------------------
      # Core CLI Tools (universal)
      #--------------------------------------------------
      bat          # Cat with syntax highlighting and Git integration
      eza          # Modern replacement for ls with colors and Git status
      fd           # Simple, fast alternative to find
      fzf          # Command-line fuzzy finder
      jq           # Lightweight JSON processor
      tree         # Display directories as trees
      colordiff    # Colorized diff output
      zoxide       # Smarter cd command that learns your habits

      #--------------------------------------------------
      # Network Essentials
      #--------------------------------------------------
      curl         # Command line tool for transferring data with URLs
      wget         # Non-interactive network downloader

      #--------------------------------------------------
      # System Utilities
      #--------------------------------------------------
      vim          # Basic text editor (for minimal systems)
      neofetch     # System information tool
      htop         # Interactive process viewer

      #--------------------------------------------------
      # File Processing & Archives
      #--------------------------------------------------
      unzip        # Extract ZIP archives
      zip          # Create ZIP archives
      gzip         # GNU compression utility

      #--------------------------------------------------
      # Text Processing
      #--------------------------------------------------
      ripgrep      # Fast text search tool (rg)
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
