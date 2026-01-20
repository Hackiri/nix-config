# Enhanced development tools helper script with modular architecture
{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) lib;

  # Define tool categories and their dependencies
  toolCategories = {
    # Core utilities always included
    core = with pkgs; [
      coreutils
      findutils
      gnused
      gnugrep
      gawk
    ];

    # Language-specific formatters
    formatters = with pkgs;
      [
        # Python
        black
        isort

        # JavaScript/TypeScript
        nodePackages.prettier

        # Rust
        rustfmt

        # Lua
        stylua

        # Nix
        alejandra

        # Shell
        shfmt

        # YAML/JSON
        yq-go

        # Go Templates
        templ
      ]
      ++ lib.optionals (lib.hasAttr "autopep8" pkgs) [
        autopep8 # Python code formatter (if available)
      ]
      ++ lib.optionals (lib.hasAttr "go" pkgs) [
        go # Go toolchain (includes gofmt)
      ]
      ++ lib.optionals (lib.hasAttr "nixfmt-rfc-style" pkgs) [
        nixfmt-rfc-style # RFC-style Nix formatter
      ];

    # Language-specific linters
    linters = with pkgs;
      [
        # Python
        ruff
        mypy

        # JavaScript/TypeScript
        nodePackages.eslint
        nodePackages.typescript

        # Rust
        clippy

        # Go
        golangci-lint

        # Nix
        statix
        deadnix

        # Shell
        shellcheck

        # CSS
        nodePackages.stylelint
      ]
      ++ lib.optionals (lib.hasAttr "pylint" pkgs) [
        pylint # Python linter (if available)
      ]
      ++ lib.optionals (lib.hasAttr "markdownlint-cli" pkgs) [
        markdownlint-cli # Markdown linter (if available)
      ];

    # Web development tools
    web = with pkgs;
      [
        python3
        caddy
      ]
      ++ lib.optionals (lib.hasAttr "http-server" pkgs.nodePackages) [
        nodePackages.http-server # Simple HTTP server
      ]
;

    # Image and media tools
    media = with pkgs;
      [
        imagemagick
        optipng
        jpegoptim
        ffmpeg-headless
      ]
      ++ lib.optionals (lib.hasAttr "libwebp" pkgs) [
        libwebp # WebP image format support
      ];

    # Database tools
    database = with pkgs; [
      sqlite
      postgresql
      redis
    ];

    # Documentation tools
    docs = with pkgs;
      [
        pandoc
      ]
      ++ lib.optionals (lib.hasAttr "mdbook" pkgs) [
        mdbook # Rust-based documentation generator
      ]
      ++ lib.optionals (lib.hasAttr "hugo" pkgs) [
        hugo # Static site generator
      ];
  };

  # Helper function to detect file types in current directory
  fileDetectionScript = ''
    # File type detection functions
    has_files() {
      local pattern="$1"
      find . -maxdepth 3 -name "$pattern" -type f | head -1 | grep -q .
    }

    detect_project_type() {
      local project_types=()

      # Language detection
      has_files "*.py" && project_types+=("python")
      has_files "*.js" && project_types+=("javascript")
      has_files "*.ts" && project_types+=("typescript")
      has_files "*.jsx" && project_types+=("react")
      has_files "*.tsx" && project_types+=("react-ts")
      has_files "*.rs" && project_types+=("rust")
      has_files "*.go" && project_types+=("go")
      has_files "*.lua" && project_types+=("lua")
      has_files "*.nix" && project_types+=("nix")
      has_files "*.sh" && project_types+=("shell")
      has_files "*.css" && project_types+=("css")
      has_files "*.scss" && project_types+=("scss")
      has_files "*.md" && project_types+=("markdown")

      # Framework detection
      has_files "package.json" && project_types+=("node")
      has_files "Cargo.toml" && project_types+=("cargo")
      has_files "go.mod" && project_types+=("gomod")
      has_files "pyproject.toml" && project_types+=("poetry")
      has_files "requirements.txt" && project_types+=("pip")
      has_files "flake.nix" && project_types+=("flake")

      printf "%s\n" "''${project_types[@]}"
    }
  '';

  # Main script with enhanced functionality
  mainScript = ''
    #!${pkgs.bash}/bin/bash

    # Set strict bash options
    set -euo pipefail

    # Color definitions for better output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color

    # Logging functions
    log_info() { echo -e "''${BLUE}ℹ️  $1''${NC}"; }
    log_success() { echo -e "''${GREEN}✅ $1''${NC}"; }
    log_warning() { echo -e "''${YELLOW}⚠️  $1''${NC}"; }
    log_error() { echo -e "''${RED}❌ $1''${NC}"; }
    log_step() { echo -e "''${PURPLE}🔄 $1''${NC}"; }

    ${fileDetectionScript}

    # Help message with dynamic content based on detected project
    show_help() {
      echo -e "''${CYAN}🛠️  Development Tools Helper''${NC}"
      echo "Usage: dev-tools <command> [args]"
      echo ""

      # Detect current project type
      local project_types
      mapfile -t project_types < <(detect_project_type)
      if [ ''${#project_types[@]} -gt 0 ]; then
        echo -e "''${GREEN}📁 Detected project types:''${NC} ''${project_types[*]}"
        echo ""
      fi

      echo "Commands:"
      echo "  clean       - Clean development artifacts"
      echo "  format      - Format code (auto-detects languages)"
      echo "  lint        - Run linters (auto-detects languages)"
      echo "  check       - Run both linting and formatting checks"
      echo "  fix         - Auto-fix issues where possible"
      echo "  web-serve   - Start a web server [port]"
      echo "  optimize    - Optimize images and media files"
      echo "  deps        - Check and update dependencies"
      echo "  test        - Run tests (auto-detects test framework)"
      echo "  build       - Build project (auto-detects build system)"
      echo "  watch       - Watch for file changes and auto-format"
      echo "  info        - Show project information and statistics"
      echo "  setup       - Set up development environment"
      echo "  help        - Show this help message"
      echo ""
      echo "Options:"
      echo "  --verbose   - Show detailed output"
      echo "  --dry-run   - Show what would be done without executing"
    }

    # Enhanced clean function with project-specific artifacts
    clean_artifacts() {
      log_step "Cleaning development artifacts..."

      local project_types
      mapfile -t project_types < <(detect_project_type)
      local cleaned=0

      # Common artifacts
      find . -name ".DS_Store" -type f -delete 2>/dev/null && cleaned=1
      find . -name "Thumbs.db" -type f -delete 2>/dev/null && cleaned=1
      find . -name "*.tmp" -type f -delete 2>/dev/null && cleaned=1
      find . -name "*.temp" -type f -delete 2>/dev/null && cleaned=1

      # Language-specific cleanup
      for project_type in "''${project_types[@]}"; do
        case "$project_type" in
          python)
            find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null && cleaned=1
            find . -type f -name "*.pyc" -delete 2>/dev/null && cleaned=1
            find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null && cleaned=1
            find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null && cleaned=1
            find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null && cleaned=1
            ;;
          node|javascript|typescript)
            find . -name "node_modules" -type d -prune -o -name "*.log" -type f -delete 2>/dev/null && cleaned=1
            find . -name ".nyc_output" -type d -exec rm -rf {} + 2>/dev/null && cleaned=1
            ;;
          rust|cargo)
            find . -name "target" -type d -exec rm -rf {} + 2>/dev/null && cleaned=1
            ;;
          go|gomod)
            find . -name "*.test" -type f -delete 2>/dev/null && cleaned=1
            ;;
        esac
      done

      if [ $cleaned -eq 1 ]; then
        log_success "Cleanup complete!"
      else
        log_info "No artifacts found to clean"
      fi
    }

    # Smart formatting based on detected languages
    format_code() {
      log_step "Formatting code..."

      local project_types
      mapfile -t project_types < <(detect_project_type)
      local formatted=0

      for project_type in "''${project_types[@]}"; do
        case "$project_type" in
          python)
            if has_files "*.py"; then
              log_info "Formatting Python files..."
              ${pkgs.black}/bin/black . && formatted=1
              ${pkgs.isort}/bin/isort . && formatted=1
            fi
            ;;
          javascript|typescript|node)
            if has_files "*.js" || has_files "*.ts" || has_files "*.jsx" || has_files "*.tsx"; then
              log_info "Formatting JavaScript/TypeScript files..."
              ${pkgs.nodePackages.prettier}/bin/prettier --write "**/*.{js,ts,jsx,tsx,json,css,md}" && formatted=1
            fi
            ;;
          rust|cargo)
            if has_files "*.rs"; then
              log_info "Formatting Rust files..."
              find . -name "*.rs" -exec ${pkgs.rustfmt}/bin/rustfmt --edition 2021 {} \; && formatted=1
            fi
            ;;
          go|gomod)
            if has_files "*.go"; then
              log_info "Formatting Go files..."
              if command -v go >/dev/null 2>&1; then
                go fmt ./... && formatted=1
              else
                log_warning "Go not available, skipping Go formatting"
              fi
            fi
            ;;
          lua)
            if has_files "*.lua"; then
              log_info "Formatting Lua files..."
              ${pkgs.stylua}/bin/stylua . && formatted=1
            fi
            ;;
          nix)
            if has_files "*.nix"; then
              log_info "Formatting Nix files..."
              ${pkgs.alejandra}/bin/alejandra -q . && formatted=1
            fi
            ;;
          shell)
            if has_files "*.sh"; then
              log_info "Formatting shell scripts..."
              find . -name "*.sh" -exec ${pkgs.shfmt}/bin/shfmt -w {} \; && formatted=1
            fi
            ;;
        esac
      done

      if [ $formatted -eq 1 ]; then
        log_success "Formatting complete!"
      else
        log_info "No files found to format"
      fi
    }

    # Smart linting based on detected languages
    lint_code() {
      log_step "Linting code..."

      local project_types
      mapfile -t project_types < <(detect_project_type)
      local linted=0
      local errors=0

      for project_type in "''${project_types[@]}"; do
        case "$project_type" in
          python)
            if has_files "*.py"; then
              log_info "Linting Python files..."
              ${pkgs.ruff}/bin/ruff check . || errors=1
              linted=1
            fi
            ;;
          javascript|typescript|node)
            if has_files "*.js" || has_files "*.ts" || has_files "*.jsx" || has_files "*.tsx"; then
              log_info "Linting JavaScript/TypeScript files..."
              ${pkgs.nodePackages.eslint}/bin/eslint --ext .js,.jsx,.ts,.tsx . || errors=1
              linted=1
            fi
            ;;
          nix)
            if has_files "*.nix"; then
              log_info "Linting Nix files..."
              ${pkgs.statix}/bin/statix check . || errors=1
              ${pkgs.deadnix}/bin/deadnix . || errors=1
              linted=1
            fi
            ;;
          shell)
            if has_files "*.sh"; then
              log_info "Linting shell scripts..."
              find . -name "*.sh" -exec ${pkgs.shellcheck}/bin/shellcheck {} \; || errors=1
              linted=1
            fi
            ;;
          css)
            if has_files "*.css"; then
              log_info "Linting CSS files..."
              ${pkgs.nodePackages.stylelint}/bin/stylelint "**/*.css" || errors=1
              linted=1
            fi
            ;;
          markdown)
            if has_files "*.md"; then
              log_info "Linting Markdown files..."
              ${pkgs.markdownlint-cli}/bin/markdownlint . || errors=1
              linted=1
            fi
            ;;
        esac
      done

      if [ $linted -eq 1 ]; then
        if [ $errors -eq 0 ]; then
          log_success "Linting complete - no issues found!"
        else
          log_warning "Linting complete - issues found (see output above)"
        fi
      else
        log_info "No files found to lint"
      fi

      return $errors
    }

    # Enhanced web server with multiple options
    web_serve() {
      local port="''${1:-8000}"
      local server_type="''${2:-auto}"

      log_step "Starting web server on port $port..."

      case "$server_type" in
        auto)
          if command -v ${pkgs.caddy}/bin/caddy >/dev/null 2>&1; then
            log_info "Using Caddy server"
            ${pkgs.caddy}/bin/caddy file-server --listen ":$port" --browse
          else
            log_info "Using Python HTTP server"
            ${pkgs.python3}/bin/python -m http.server "$port"
          fi
          ;;
        python)
          ${pkgs.python3}/bin/python -m http.server "$port"
          ;;
        caddy)
          ${pkgs.caddy}/bin/caddy file-server --listen ":$port" --browse
          ;;
        *)
          log_error "Unknown server type: $server_type"
          return 1
          ;;
      esac
    }

    # Enhanced image optimization
    optimize_images() {
      log_step "Optimizing images..."

      local optimized=0

      # JPEG optimization
      find . -type f \( -name "*.jpg" -o -name "*.jpeg" \) | while read -r img; do
        log_info "Optimizing JPEG: $img"
        ${pkgs.jpegoptim}/bin/jpegoptim --strip-all --max=85 "$img" && optimized=1
      done

      # PNG optimization
      find . -type f -name "*.png" | while read -r img; do
        log_info "Optimizing PNG: $img"
        ${pkgs.optipng}/bin/optipng -o2 "$img" && optimized=1
      done

      # WebP conversion for large images
      find . -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) | while read -r img; do
        local size
        size=$(stat -f%z "$img" 2>/dev/null || stat -c%s "$img" 2>/dev/null || echo 0)
        if [ "$size" -gt 500000 ]; then # > 500KB
          local webp_name="''${img%.*}.webp"
          if [ ! -f "$webp_name" ]; then
            log_info "Creating WebP version: $webp_name"
            ${pkgs.imagemagick}/bin/convert "$img" -quality 80 "$webp_name" && optimized=1
          fi
        fi
      done

      if [ $optimized -eq 1 ]; then
        log_success "Image optimization complete!"
      else
        log_info "No images found to optimize"
      fi
    }

    # Project information and statistics
    show_info() {
      log_step "Gathering project information..."

      echo ""
      echo -e "''${CYAN}📊 Project Statistics''${NC}"
      echo "===================="

      # Basic file counts
      echo "📁 Total files: $(find . -type f | wc -l)"
      echo "📂 Total directories: $(find . -type d | wc -l)"

      # Language breakdown
      local project_types
      mapfile -t project_types < <(detect_project_type)
      if [ ''${#project_types[@]} -gt 0 ]; then
        echo ""
        echo -e "''${GREEN}🔤 Detected Languages:''${NC}"
        for lang in "''${project_types[@]}"; do
          case "$lang" in
            python) echo "  🐍 Python: $(find . -name "*.py" | wc -l) files" ;;
            javascript) echo "  📜 JavaScript: $(find . -name "*.js" | wc -l) files" ;;
            typescript) echo "  📘 TypeScript: $(find . -name "*.ts" | wc -l) files" ;;
            rust) echo "  🦀 Rust: $(find . -name "*.rs" | wc -l) files" ;;
            go) echo "  🐹 Go: $(find . -name "*.go" | wc -l) files" ;;
            nix) echo "  ❄️  Nix: $(find . -name "*.nix" | wc -l) files" ;;
          esac
        done
      fi

      # Git information if available
      if [ -d ".git" ]; then
        echo ""
        echo -e "''${PURPLE}📋 Git Information:''${NC}"
        echo "  Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
        echo "  Commits: $(git rev-list --count HEAD 2>/dev/null || echo 'unknown')"
        echo "  Last commit: $(git log -1 --format='%cr' 2>/dev/null || echo 'unknown')"
      fi

      echo ""
    }

    # Main command handler with better argument parsing
    VERBOSE=false

    # Parse global options
    while [[ $# -gt 0 ]]; do
      case $1 in
        --verbose)
          VERBOSE=true
          shift
          ;;
        --dry-run)
          # Dry run option recognized but not implemented yet
          log_info "Dry run mode not yet implemented"
          shift
          ;;
        -*)
          log_error "Unknown option: $1"
          show_help
          exit 1
          ;;
        *)
          break
          ;;
      esac
    done

    # Set verbose mode
    if [ "$VERBOSE" = true ]; then
      set -x
    fi

    # Main command dispatch
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
      "check")
        lint_code && format_code
        ;;
      "fix")
        format_code && lint_code
        ;;
      "web-serve")
        web_serve "''${2:-8000}" "''${3:-auto}"
        ;;
      "optimize")
        optimize_images
        ;;
      "info")
        show_info
        ;;
      "help"|*)
        show_help
        ;;
    esac
  '';
in
  pkgs.writeShellApplication {
    name = "dev-tools";
    text = mainScript;
    runtimeInputs = with pkgs;
      toolCategories.core
      ++ toolCategories.formatters
      ++ toolCategories.linters
      ++ toolCategories.web
      ++ toolCategories.media
      ++ toolCategories.docs;
  }
