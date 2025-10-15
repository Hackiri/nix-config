# Package Collections - Documentation and Reference
#
# This file serves as documentation for all available package collections.
# Packages are imported individually in the appropriate profile files rather than
# through this aggregator to provide better control and clarity.
#
# IMPORT LOCATIONS:
# - development.nix: build-tools, code-quality, databases, languages, network, 
#                    security, terminals, web-dev, custom
# - desktop.nix: desktop, utilities
#
# NOTE: This file is NOT imported anywhere and exists only as documentation.
# To add packages to your configuration, import the specific .nix file in the
# appropriate profile (minimal.nix, development.nix, or desktop.nix).
#
# Available Package Collections:
# ------------------------------
# ./build-tools.nix    - Build tools, compilers, and core dev utilities
# ./code-quality.nix   - Linters, formatters, and code analysis tools
# ./custom/            - Custom overlay packages
# ./databases.nix      - Database client tools (psql, redis-cli, mongosh, etc.)
# ./desktop.nix        - Desktop applications and GUI tools
# ./languages.nix      - Programming language runtimes (Node, Python, Go, Rust, etc.)
# ./network.nix        - Network utilities and tools (cachix)
# ./security.nix       - Security and encryption tools (sops, age)
# ./system.nix         - System-specific utilities
# ./terminals.nix      - Terminal applications and tools (tmuxinator, moreutils)
# ./utilities.nix      - Media and document processing (imagemagick, ghostscript)
# ./web-dev.nix        - Web development tools (httpie, curl, grpcurl, caddy)

# This is a placeholder module that does nothing
{pkgs, ...}: {
  # No imports - packages are imported directly in profile files
}
