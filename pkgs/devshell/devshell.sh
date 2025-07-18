#!/usr/bin/env bash

# Devshell launcher script
# Usage: devshell [languages...]
# Example: devshell python rust

# Set shell options for better compatibility
set -o posix

# Default to all languages if none specified
LANGUAGES=("$@")
if [ ${#LANGUAGES[@]} -eq 0 ]; then
  LANGUAGES=("python" "rust" "go" "node")
fi

# Detect shell type
SHELL_TYPE="bash"
if [ -n "$ZSH_VERSION" ]; then
  SHELL_TYPE="zsh"
fi

# Function to show welcome message
show_welcome() {
  echo "🚀 Entering development environment"
  echo ""
  echo "📂 Project: $(basename "$(pwd)")"
  
  # Show environments based on enabled languages
  for lang in "${LANGUAGES[@]}"; do
    case "$lang" in
      python)
        echo "🐍 Python environment: $VENV_DIR"
        ;;
      go)
        echo "🐹 Go environment: $GOPATH"
        ;;
      node)
        echo "📦 Node environment: $NODE_PATH"
        ;;
      rust)
        echo "⚙️  Rust environment: $CARGO_HOME"
        ;;
    esac
  done

  echo ""
  echo "🔧 Tool versions:"
  
  # Show versions based on enabled languages
  for lang in "${LANGUAGES[@]}"; do
    case "$lang" in
      python)
        command -v python3 >/dev/null && echo "🔷 Python: $(python3 --version 2>&1)"
        ;;
      go)
        command -v go >/dev/null && echo "🐹 Go: $(go version 2>&1)"
        ;;
      node)
        command -v node >/dev/null && echo "⬢ Node: $(node --version 2>&1)"
        ;;
      rust)
        command -v rustc >/dev/null && echo "🦀 Rust: $(rustc --version 2>&1)"
        ;;
    esac
  done
  
  echo "🌳 Git: $(git --version 2>&1)"
  echo "🔒 Nix: $(nix --version 2>&1)"

  echo ""
  echo "💡 Quick Tips:"
  echo "• Use 'just' for project-specific commands"
  echo "• 'lazygit' for git TUI"
  echo "• 'bottom' or 'btm' for system monitoring"
  echo "• 'zoxide' for smart directory jumping"
}

# Skip sourcing user shell config files to avoid compatibility issues
# Instead, set up a minimal environment

# Source Nix profile directly
[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && source "$HOME/.nix-profile/etc/profile.d/nix.sh"

# Set up language-specific environments
for lang in "${LANGUAGES[@]}"; do
  case "$lang" in
    python)
      # Use python3 from PATH
      PYTHON_BIN=$(command -v python3 2>/dev/null)
      if [ -n "$PYTHON_BIN" ]; then
        PYTHON_VERSION=$($PYTHON_BIN --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1-2)
        export PYTHONPATH="$HOME/.local/lib/python$PYTHON_VERSION/site-packages:$PYTHONPATH"
        export VENV_DIR="$HOME/.local/lib/python$PYTHON_VERSION/site-packages"
      else
        export PYTHONPATH="$HOME/.local/lib/python3.12/site-packages:$PYTHONPATH"
        export VENV_DIR="$HOME/.local/lib/python3.12/site-packages"
      fi
      ;;
    go)
      export GOPATH="$HOME/go"
      export PATH="$GOPATH/bin:$PATH"
      ;;
    node)
      export NODE_PATH="$HOME/.npm-packages/lib/node_modules"
      export PATH="$HOME/.npm-packages/bin:$PATH"
      ;;
    rust)
      export CARGO_HOME="$HOME/.cargo"
      export RUSTUP_HOME="$HOME/.rustup"
      export PATH="$CARGO_HOME/bin:$PATH"
      ;;
  esac
done

# Set common environment variables
export EDITOR="hx"
export VISUAL="hx"
export PAGER="less -R"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Show welcome message
show_welcome

# If this script is sourced, keep the shell open
# If run directly, start a new shell
if [ -n "$BASH_VERSION" ] && [ "${BASH_SOURCE[0]}" != "${0}" ]; then
  # Script is being sourced in bash, do nothing
  :
elif [ -n "$ZSH_VERSION" ] && [ "$ZSH_EVAL_CONTEXT" = "toplevel:file" ]; then
  # Script is being sourced in zsh, do nothing
  :
else
  # Script is being run directly, start a new shell
  # Determine preferred shell
  if [ -n "$SHELL" ] && [ -x "$SHELL" ]; then
    PREFERRED_SHELL="$SHELL"
  elif command -v bash >/dev/null 2>&1; then
    PREFERRED_SHELL="$(command -v bash)"
  else
    PREFERRED_SHELL="/bin/sh"
  fi
  
  # Preserve important environment variables when launching a new shell
  # Use --login to ensure proper initialization
  if [[ "$PREFERRED_SHELL" == *"bash"* ]]; then
    exec "$PREFERRED_SHELL" --norc -c "
      export HOME='$HOME';
      export PATH='$PATH';
      export TERM='$TERM';
      export USER='$USER';
      export PYTHONPATH='$PYTHONPATH';
      export GOPATH='$GOPATH';
      export NODE_PATH='$NODE_PATH';
      export CARGO_HOME='$CARGO_HOME';
      export RUSTUP_HOME='$RUSTUP_HOME';
      export EDITOR='$EDITOR';
      export VISUAL='$VISUAL';
      export PAGER='$PAGER';
      export MANPAGER='$MANPAGER';
      export DEVSHELL='true';
      exec bash --norc"
  else
    # For other shells, use simpler approach
    exec "$PREFERRED_SHELL"
  fi
fi
