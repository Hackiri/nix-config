{pkgs ? import <nixpkgs> {}}:
# This is the main package set for custom packages
# Each attribute in this set is a package
{
  # Development helper scripts
  dev-tools =
    pkgs.callPackage
    (
      {pkgs}: let
        name = "dev-tools";
        script = ''
          #!${pkgs.bash}/bin/bash

          # Set strict bash options
          set -euo pipefail

          # Help message
          show_help() {
            echo "Development Tools Helper"
            echo "Usage: dev-tools <command> [args]"
            echo ""
            echo "Commands:"
            echo "  clean     - Clean development artifacts (*.pyc, __pycache__, etc.)"
            echo "  format    - Format code in the current directory"
            echo "  lint      - Run linters on the code"
            echo "  web-serve - Start a simple web server in the current directory"
            echo "  optimize  - Optimize images in the current directory"
            echo "  css-check - Check CSS for issues"
            echo "  help      - Show this help message"
          }

          # Clean development artifacts
          clean_artifacts() {
            echo "🧹 Cleaning development artifacts..."
            find . -type d -name "__pycache__" -exec rm -rf {} +
            find . -type f -name "*.pyc" -delete
            find . -type f -name ".DS_Store" -delete
            find . -type d -name ".pytest_cache" -exec rm -rf {} +
            find . -type d -name ".mypy_cache" -exec rm -rf {} +
            echo "✨ Clean complete!"
          }

          # Format code
          format_code() {
            echo "🎨 Formatting code..."
            if [ -f "*.py" ]; then
              ${pkgs.black}/bin/black .
            fi
            if [ -f "*.lua" ]; then
              ${pkgs.stylua}/bin/stylua .
            fi
            if [ -f "*.nix" ]; then
              ${pkgs.alejandra}/bin/alejandra -q .
            fi
            echo "✨ Formatting complete!"
          }

          # Lint code
          lint_code() {
            echo "🔍 Linting code..."
            if [ -f "*.py" ]; then
              ${pkgs.ruff}/bin/ruff check .
            fi
            if [ -f "*.nix" ]; then
              ${pkgs.statix}/bin/statix check .
            fi
            if [ -f "*.js" ] || [ -f "*.jsx" ] || [ -f "*.ts" ] || [ -f "*.tsx" ]; then
              ${pkgs.nodePackages.eslint}/bin/eslint --ext .js,.jsx,.ts,.tsx .
            fi
            echo "✨ Linting complete!"
          }

          # Start a simple web server
          web_serve() {
            echo "🌐 Starting web server in the current directory..."
            PORT=''${1:-8000}
            echo "Server running at http://localhost:$PORT"
            ${pkgs.python3}/bin/python -m http.server "$PORT"
          }

          # Optimize images
          optimize_images() {
            echo "🖼️ Optimizing images..."
            find . -type f -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" | while read -r img; do
              echo "Optimizing $img"
              ${pkgs.imagemagick}/bin/convert "$img" -strip -interlace Plane -quality 85% "$img"
            done
            echo "✨ Image optimization complete!"
          }

          # Check CSS for issues
          check_css() {
            echo "🎨 Checking CSS..."
            if [ -f "*.css" ]; then
              ${pkgs.nodePackages.stylelint}/bin/stylelint "**/*.css"
            fi
            echo "✨ CSS check complete!"
          }

          # Main command handler
          case "''${1:-help}" in
            "clean")
              clean_artifacts
              ;;
            "format")
              format_code
              ;;
            "lint")
              lint_code
              ;;
            "web-serve")
              web_serve "$2"
              ;;
            "optimize")
              optimize_images
              ;;
            "css-check")
              check_css
              ;;
            "help"|*)
              show_help
              ;;
          esac
        '';
      in
        pkgs.writeShellApplication {
          inherit name;
          text = script;
          runtimeInputs = with pkgs; [
            # Basic utilities
            coreutils
            findutils

            # Development tools
            black
            ruff
            stylua
            alejandra
            statix

            # Web development tools
            python3
            nodePackages.eslint
            nodePackages.stylelint
            nodePackages.prettier

            # UI/UX tools
            imagemagick
            optipng
            jpegoptim
          ];
        }
    )
    {};

  # Add other custom packages here as needed
}
