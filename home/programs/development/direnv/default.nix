_: {
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;

    config = {
      # Configuration for direnv.toml
      warn_timeout = "10s"; # Increased timeout for complex environments
      strict_env = true; # More secure environment handling
      load_dotenv = false; # Opt-in via explicit 'dotenv' in .envrc

      # Global configuration
      global = {
        hide_env_diff = false; # Show environment changes for debugging
        disable_stdin = false; # Allow stdin for interactive commands
      };
    };

    # Enhanced stdlib with better error handling and performance
    stdlib = ''
      # Enhanced use_flake with better error handling and caching
      use_flake() {
        watch_file flake.nix
        watch_file flake.lock

        # Create layout directory with better path handling
        local layout_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/direnv/layouts/$(pwd | sed 's|/|_|g')"
        mkdir -p "$layout_dir"

        # Parse arguments more robustly
        local impure=""
        local extra_args=()

        while [[ $# -gt 0 ]]; do
          case $1 in
            --impure)
              impure="--impure"
              shift
              ;;
            *)
              extra_args+=("$1")
              shift
              ;;
          esac
        done

        # Check if flake.nix exists
        if [[ ! -f flake.nix ]]; then
          log_error "No flake.nix found in current directory"
          return 1
        fi

        # Cache file for faster subsequent loads
        local cache_file="$layout_dir/flake-env"
        local flake_hash_file="$layout_dir/flake-hash"
        local current_hash

        # Generate hash of flake files for cache invalidation
        if command -v sha256sum >/dev/null 2>&1; then
          current_hash=$(cat flake.nix flake.lock 2>/dev/null | sha256sum | cut -d' ' -f1)
        elif command -v shasum >/dev/null 2>&1; then
          current_hash=$(cat flake.nix flake.lock 2>/dev/null | shasum -a 256 | cut -d' ' -f1)
        else
          current_hash=$(date +%s) # Fallback to timestamp
        fi

        # Check if cache is valid
        local cached_hash=""
        if [[ -f "$flake_hash_file" ]]; then
          cached_hash=$(cat "$flake_hash_file")
        fi

        if [[ "$current_hash" != "$cached_hash" || ! -f "$cache_file" ]]; then
          if [[ -n $impure ]]; then
            log_status "Building impure flake environment..."
          else
            log_status "Building pure flake environment..."
          fi

          # Default to current directory flake if no args given
          if (( ''${#extra_args[@]} == 0 )); then
            extra_args=(".")
          fi

          # Build environment with error handling
          if ! nix print-dev-env $impure "''${extra_args[@]}" > "$cache_file" 2>"$layout_dir/build.log"; then
            log_error "Failed to build flake environment. Check $layout_dir/build.log for details."
            return 1
          fi

          # Save hash for cache validation
          echo "$current_hash" > "$flake_hash_file"
          log_status "Environment cached successfully"
        else
          log_status "Using cached flake environment"
        fi

        # Source the environment
        if [[ -f "$cache_file" ]]; then
          source "$cache_file"
        else
          log_error "Environment file not found: $cache_file"
          return 1
        fi
      }

      # Enhanced layout_poetry with better error handling
      layout_poetry() {
        if [[ ! -f pyproject.toml ]]; then
          log_error 'No pyproject.toml found. Use `poetry new` or `poetry init` to create one first.'
          return 1
        fi

        # Check if poetry is available
        if ! command -v poetry >/dev/null 2>&1; then
          log_error 'Poetry not found. Please install poetry first.'
          return 1
        fi

        # Create layout directory
        local layout_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/direnv/layouts/$(pwd | sed 's|/|_|g')"
        mkdir -p "$layout_dir"

        log_status "Setting up Poetry environment..."

        # Get or create virtual environment
        local VENV
        VENV=$(poetry env info --path 2>/dev/null)

        if [[ -z "$VENV" || ! -d "$VENV/bin" ]]; then
          log_status "Creating new Poetry virtual environment..."
          if ! poetry install; then
            log_error "Failed to install Poetry dependencies"
            return 1
          fi
          VENV=$(poetry env info --path)
        fi

        if [[ -z "$VENV" ]]; then
          log_error "Failed to determine Poetry virtual environment path"
          return 1
        fi

        # Export environment variables
        export VIRTUAL_ENV="$VENV"
        export POETRY_ACTIVE=1
        PATH_add "$VENV/bin"

        log_status "Poetry environment activated: $VENV"
      }

      # Enhanced layout_node with package manager detection
      layout_node() {
        if [[ ! -f package.json ]]; then
          log_error 'No package.json found'
          return 1
        fi

        # Create layout directory
        local layout_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/direnv/layouts/$(pwd | sed 's|/|_|g')"
        mkdir -p "$layout_dir"

        log_status "Setting up Node.js environment..."

        # Detect package manager
        local pkg_manager="npm"
        if [[ -f yarn.lock ]]; then
          pkg_manager="yarn"
        elif [[ -f pnpm-lock.yaml ]]; then
          pkg_manager="pnpm"
        elif [[ -f bun.lockb ]]; then
          pkg_manager="bun"
        fi

        log_status "Detected package manager: $pkg_manager"

        # Install dependencies if needed
        if [[ ! -d node_modules ]]; then
          log_status "Installing Node.js dependencies with $pkg_manager..."
          case $pkg_manager in
            yarn)
              if command -v yarn >/dev/null 2>&1; then
                yarn install
              else
                log_error "Yarn not found, falling back to npm"
                npm install
              fi
              ;;
            pnpm)
              if command -v pnpm >/dev/null 2>&1; then
                pnpm install
              else
                log_error "pnpm not found, falling back to npm"
                npm install
              fi
              ;;
            bun)
              if command -v bun >/dev/null 2>&1; then
                bun install
              else
                log_error "bun not found, falling back to npm"
                npm install
              fi
              ;;
            *)
              npm install
              ;;
          esac
        fi

        # Add node_modules/.bin to PATH
        local node_modules="$(pwd)/node_modules"
        if [[ -d "$node_modules/.bin" ]]; then
          PATH_add "$node_modules/.bin"
          log_status "Added $node_modules/.bin to PATH"
        fi

        # Set NODE_ENV if not already set
        export NODE_ENV="''${NODE_ENV:-development}"
      }

      # Layout for Rust projects
      layout_rust() {
        if [[ ! -f Cargo.toml ]]; then
          log_error 'No Cargo.toml found'
          return 1
        fi

        log_status "Setting up Rust environment..."

        # Create layout directory
        local layout_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/direnv/layouts/$(pwd | sed 's|/|_|g')"
        mkdir -p "$layout_dir"

        # Set Rust environment variables
        export CARGO_TARGET_DIR="''${CARGO_TARGET_DIR:-$layout_dir/target}"
        export RUST_BACKTRACE="''${RUST_BACKTRACE:-1}"

        # Add cargo bin to PATH if it exists
        if [[ -d "$HOME/.cargo/bin" ]]; then
          PATH_add "$HOME/.cargo/bin"
        fi

        log_status "Rust environment configured"
      }

      # Layout for Go projects
      layout_go() {
        if [[ ! -f go.mod ]]; then
          log_error 'No go.mod found'
          return 1
        fi

        log_status "Setting up Go environment..."

        # Create layout directory
        local layout_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/direnv/layouts/$(pwd | sed 's|/|_|g')"
        mkdir -p "$layout_dir"

        # Set Go environment variables
        export GOPATH="$layout_dir/go"
        export GOCACHE="$layout_dir/gocache"
        export GOMODCACHE="$layout_dir/gomodcache"

        # Create Go directories
        mkdir -p "$GOPATH/bin" "$GOCACHE" "$GOMODCACHE"

        # Add Go bin to PATH
        PATH_add "$GOPATH/bin"

        log_status "Go environment configured with GOPATH: $GOPATH"
      }
    '';
  };
}
