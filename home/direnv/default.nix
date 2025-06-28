{pkgs, ...}: {
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;

    config = {
      # Configuration for direnv.toml
      warn_timeout = "5s"; # Warn if direnv takes more than 5 seconds to load
      strict_env = true; # More secure environment handling
      load_dotenv = true; # Load .env files automatically
    };

    # Using triple quotes to avoid Nix string interpolation issues
    stdlib = ''
      # Use flake in current directory with proper layout directory
      use_flake() {
        watch_file flake.nix
        watch_file flake.lock

        # Create layout directory
        local layout_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/direnv/layouts/''${PWD}"
        mkdir -p "$layout_dir"

        local impure=""
        if [[ $# = 1 ]]; then
          if [[ $1 = "--impure" ]]; then
            impure="--impure"
          fi
        fi

        if [[ -n $impure ]]; then
          log_status "Loading impure flake..."
        else
          log_status "Loading pure flake..."
        fi

        nix print-dev-env $impure > "$layout_dir/flake-env"
        source "$layout_dir/flake-env"
      }

      # Layout for Python Poetry projects
      layout_poetry() {
        if [[ ! -f pyproject.toml ]]; then
          log_error 'No pyproject.toml found. Use `poetry new` or `poetry init` to create one first.'
          return 1
        fi

        # Create layout directory
        local layout_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/direnv/layouts/''${PWD}"
        mkdir -p "$layout_dir"

        local VENV=$(poetry env info --path 2>/dev/null)
        if [[ -z $VENV || ! -d $VENV/bin ]]; then
          poetry install
          VENV=$(poetry env info --path)
        fi

        export VIRTUAL_ENV=$VENV
        export POETRY_ACTIVE=1
        PATH_add "$VENV/bin"
      }

      # Layout for Node.js projects
      layout_node() {
        if [[ ! -f package.json ]]; then
          log_error 'No package.json found'
          return 1
        fi

        # Create layout directory
        local layout_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/direnv/layouts/''${PWD}"
        mkdir -p "$layout_dir"

        local node_modules="$(pwd)/node_modules"
        PATH_add "$node_modules/.bin"
      }
    '';
  };
}
