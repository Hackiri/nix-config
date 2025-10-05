# Main package collection - imports all package categories
# This file consolidates all package installations across different categories
# for better organization and maintainability.
{pkgs, ...}: {
  imports = [
    # Core development tools
    ./build-tools.nix # Build tools, compilers, and core dev utilities
    ./languages.nix # Programming language runtimes (Node, Python, Go, Rust, Ruby, PHP)

    # Quality and utilities
    ./code-quality.nix # Linters, formatters, and code analysis
    ./utilities.nix # Media and document processing
    ./network.nix # Network utilities and tools
    ./system.nix # System-specific utilities

    # Development categories
    ./databases.nix # Database client tools (PostgreSQL, Redis, MongoDB, etc.)
    ./web-dev.nix # Web development tools (servers, HTTP clients, testing)

    # Application categories
    ./security.nix # Security and encryption tools
    ./desktop.nix # Desktop applications and GUI tools
    ./terminals.nix # Terminal applications and tools
  ];
}
