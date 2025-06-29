#!/bin/bash

# Devshell launcher script
# Usage: devshell [languages...]
# Example: devshell python rust

# Default to all languages if none specified
LANGUAGES=("$@")
if [ ${#LANGUAGES[@]} -eq 0 ]; then
  LANGUAGES=("python" "rust" "go" "node")
fi

# Function to show welcome message
show_welcome() {
  echo "🚀 Entering development environment"
  echo ""
  echo "📂 Project: $(basename $(pwd))"
  
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

# Source environment files
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"
[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && source "$HOME/.nix-profile/etc/profile.d/nix.sh"

# Set up language-specific environments
for lang in "${LANGUAGES[@]}"; do
  case "$lang" in
    python)
      export PYTHONPATH="$HOME/.local/lib/python3.12/site-packages:/etc/profiles/per-user/wm/lib/python3.12/site-packages:$PYTHONPATH"
      export VENV_DIR="$HOME/.local/lib/python3.12/site-packages"
      # Ensure pip is properly linked
      if [ -f "/etc/profiles/per-user/wm/bin/pip3" ]; then
        ln -sf /etc/profiles/per-user/wm/bin/pip3 /etc/profiles/per-user/wm/bin/pip 2>/dev/null || true
      fi
      ;;
    go)
      export GOPATH="$HOME/go"
      export PATH="$GOPATH/bin:$PATH"
      ;;
    node)
      export NODE_PATH="$HOME/.npm-packages/lib/node_modules"
      ;;
    rust)
      [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
      export CARGO_HOME="$HOME/.cargo"
      export RUSTUP_HOME="$HOME/.rustup"
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
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  # Script is being sourced, do nothing
  :
else
  # Script is being run directly, start a new shell
  exec $SHELL
fi
