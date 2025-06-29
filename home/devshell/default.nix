{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.devshell = with lib; {
    enable = mkEnableOption "devshell configuration";
    features = {
      python = mkEnableOption "Python development environment";
      rust = mkEnableOption "Rust development environment";
      go = mkEnableOption "Go development environment";
      node = mkEnableOption "Node.js development environment";
    };
  };

  config = lib.mkIf config.programs.devshell.enable {
    home.packages = with pkgs; let
      # Create the devshell script as a package
      devshellScript = writeShellScriptBin "devshell" (builtins.readFile ./devshell.sh);
      # Core packages that are always included
      corePackages = [
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
        
        # Editor
        helix
        
        # Utilities
        lazygit
        difftastic
        colordiff
        tokei
        hyperfine
        just
        taplo
      ];

      # Rust packages
      rustPackages = lib.optionals config.programs.devshell.features.rust [
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
      ];

      # Go packages
      goPackages = lib.optionals config.programs.devshell.features.go [
        go
      ];

      # Node.js packages
      nodePackages = lib.optionals config.programs.devshell.features.node [
        pnpm
        yarn
        bun
        nodejs_22
      ];

      # Python packages
      pythonPackages = lib.optionals config.programs.devshell.features.python [
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
      ];

      # Platform-specific packages
      darwinPackages = [];
      linuxPackages = lib.optionals (!pkgs.stdenv.isDarwin) [
        valgrind
      ];
    in
      [ devshellScript ] # Add the devshell script to packages
      ++ corePackages
      ++ rustPackages
      ++ goPackages
      ++ nodePackages
      ++ pythonPackages
      ++ (if pkgs.stdenv.isDarwin then darwinPackages else linuxPackages);

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history.size = 10000;
      history.path = "${config.home.homeDirectory}/.zsh_history";

      initContent = let
        pythonEnabled = config.programs.devshell.features.python;
        rustEnabled = config.programs.devshell.features.rust;
        goEnabled = config.programs.devshell.features.go;
        nodeEnabled = config.programs.devshell.features.node;
      in ''
        # Function to show welcome message
        show_welcome() {
          echo "🚀 Entering development environment"
          echo ""
          echo "📂 Project: $(basename $(pwd))"
          ${lib.optionalString pythonEnabled ''echo "🐍 Python environment: $VENV_DIR"''}
          ${lib.optionalString goEnabled ''echo "🐹 Go environment: $GOPATH"''}
          ${lib.optionalString nodeEnabled ''echo "📦 Node environment: $NODE_PATH"''}
          ${lib.optionalString rustEnabled ''echo "⚙️  Rust environment: $CARGO_HOME"''}

          echo ""
          echo "🔧 Tool versions:"
          ${lib.optionalString pythonEnabled ''command -v python3 >/dev/null && echo "🔷 Python: $(python3 --version 2>&1)"''}
          ${lib.optionalString goEnabled ''command -v go >/dev/null && echo "🐹 Go: $(go version 2>&1)"''}
          ${lib.optionalString nodeEnabled ''command -v node >/dev/null && echo "⬢ Node: $(node --version 2>&1)"''}
          ${lib.optionalString rustEnabled ''command -v rustc >/dev/null && echo "🦀 Rust: $(rustc --version 2>&1)"''}
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
          ${lib.optionalString rustEnabled ''[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"''}
          [ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"
          [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && source "$HOME/.nix-profile/etc/profile.d/nix.sh"

          # Set environment variables
          ${lib.optionalString pythonEnabled ''
          export PYTHONPATH="$HOME/.local/lib/python3.12/site-packages:/etc/profiles/per-user/wm/lib/python3.12/site-packages:$PYTHONPATH"
          export VENV_DIR="$HOME/.local/lib/python3.12/site-packages"

          # Ensure pip is properly linked
          if [ -f "/etc/profiles/per-user/wm/bin/pip3" ]; then
            ln -sf /etc/profiles/per-user/wm/bin/pip3 /etc/profiles/per-user/wm/bin/pip 2>/dev/null || true
          fi
          ''}
          
          ${lib.optionalString goEnabled ''
          export GOPATH="$HOME/go"
          export PATH="$GOPATH/bin:$PATH"
          ''}
          
          ${lib.optionalString nodeEnabled ''
          export NODE_PATH="$HOME/.npm-packages/lib/node_modules"
          ''}
          
          ${lib.optionalString rustEnabled ''
          export CARGO_HOME="$HOME/.cargo"
          export RUSTUP_HOME="$HOME/.rustup"
          ''}
          
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
