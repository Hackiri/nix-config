{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.devshell = with lib; {
    enable = mkEnableOption "devshell configuration";
  };

  config = lib.mkIf config.programs.devshell.enable {
    home.packages = with pkgs;
      [
        # Shell and terminal utilities

        fzf
        bat
        eza
        fd
        ripgrep
        jq
        yq-go
        tree
        htop
        git
        git-lfs
        direnv
        nix-direnv
        zoxide
        bottom
        du-dust
        duf
        procs
        sd
        choose

        # Development tools
        gh
        gnumake
        ninja
        gcc
        go

        # Rust development tools
        rustc
        cargo
        rustfmt
        clippy
        rust-analyzer
        cargo-edit
        cargo-watch
        cargo-audit
        cargo-expand
        cargo-tarpaulin

        # JavaScript/TypeScript development
        pnpm
        yarn
        bun
        nodejs_22

        taplo
        python3
        python3Packages.pip
        python3Packages.pipx
        python3Packages.pygments
        python3Packages.pytest_7
        python3Packages.pylint
        python3Packages.markdown
        python3Packages.tabulate
        python3Packages.pynvim
        uv
        lazygit
        difftastic
        colordiff
        helix
        tokei
        hyperfine
        just

        # Build tools
        pkg-config
        autoconf
        automake
        libtool

        # Debugging and analysis
        gdb
        lldb_17

        # Additional CLI tools
        curl
        wget
        tmux
        neofetch
        glow
        xh
        jless
        fx
        unzip

        # Version control and code quality
        git-crypt
        pre-commit
        shellcheck
        nixpkgs-fmt
        alejandra
        deadnix
        statix
        stylua
      ]
      ++ lib.optionals (!pkgs.stdenv.isDarwin) [
        valgrind
      ];

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history.size = 10000;
      history.path = "${config.home.homeDirectory}/.zsh_history";

      initContent = ''
        # Function to show welcome message
        show_welcome() {
          echo "🚀 Entering development environment"
          echo ""
          echo "📂 Project: $(basename $(pwd))"
          echo "🐍 Python environment: $VENV_DIR"
          echo "🐹 Go environment: $GOPATH"
          echo "📦 Node environment: $NODE_PATH"
          echo "⚙️  Rust environment: $CARGO_HOME"

          echo ""
          echo "🔧 Tool versions:"
          echo "🔷 Python: $(python3 --version 2>&1)"
          echo "🐹 Go: $(go version 2>&1)"
          echo "⬢ Node: $(node --version 2>&1)"
          echo "🦀 Rust: $(rustc --version 2>&1)"
          echo "🌳 Git: $(git --version 2>&1)"
          echo "🔒 Nix: $(nix --version 2>&1)"

          echo ""
          echo "💡 Quick Tips:"
          echo "• Use 'just' for project-specific commands"
          echo "• 'lazygit' for git TUI"
          echo "• 'bottom' or 'btm' for system monitoring"
          echo "• 'zoxide' for smart directory jumping"
        }

        # Function to initialize development environment
        devshellInit() {
          # Source environment files
          [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
          [ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"
          [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && source "$HOME/.nix-profile/etc/profile.d/nix.sh"

          # Set environment variables
          export PYTHONPATH="$HOME/.local/lib/python3.12/site-packages:/etc/profiles/per-user/wm/lib/python3.12/site-packages:$PYTHONPATH"
          export VENV_DIR="$HOME/.local/lib/python3.12/site-packages"

          # Ensure pip is properly linked
          if [ -f "/etc/profiles/per-user/wm/bin/pip3" ]; then
            ln -sf /etc/profiles/per-user/wm/bin/pip3 /etc/profiles/per-user/wm/bin/pip 2>/dev/null || true
          fi
          export GOPATH="$HOME/go"
          export PATH="$GOPATH/bin:$PATH"
          export NODE_PATH="$HOME/.npm-packages/lib/node_modules"
          export CARGO_HOME="$HOME/.cargo"
          export RUSTUP_HOME="$HOME/.rustup"
          export EDITOR="hx"
          export VISUAL="hx"
          export PAGER="less -R"
          export MANPAGER="sh -c 'col -bx | bat -l man -p'"

          # Show welcome message
          show_welcome
        }

        # Alias to manually enter development environment
        alias devshell='devshellInit'

        # Auto-run devshellInit when shell starts in nix develop
        if [ -n "$IN_NIX_SHELL" ]; then
          devshellInit
        fi
      '';

      shellAliases = {};
    };

    # Direnv configuration moved to modules/home-manager/cli/direnv.nix
  };
}
