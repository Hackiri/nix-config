# Main package collection - imports all package categories
# This file consolidates all package installations across different categories
# for better organization and maintainability.
{pkgs, ...}: {
  imports = [
    # Core development tools
    ./dev-tools.nix # Development tools and utilities (combines cli-tools + build-tools)
    ./languages.nix # Programming language runtimes
    ./python.nix # Python-specific packages

    # Quality and utilities
    ./code-quality.nix # Linters, formatters, and code analysis
    ./utilities.nix # Media and document processing
    ./network.nix # Network utilities and tools
    ./system.nix # System-specific utilities

    # Application categories
    ./security.nix # Security and encryption tools
    ./desktop.nix # Desktop applications and GUI tools
    ./terminals.nix # Terminal applications and tools
  ];
}
