{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) lib;

  # Import configuration
  config = import ./config.nix;

  # Extract enabled features
  inherit (config.programs.devshell) features;

  # Enhanced language-specific packages with better tooling
  languagePackages = {
    python = with pkgs;
      lib.optionals features.python ([
          # Core Python
          python3
          python3Packages.pip
          python3Packages.virtualenv

          # Development tools
          python3Packages.black
          python3Packages.isort
          python3Packages.ruff
          python3Packages.mypy
          python3Packages.pytest
          python3Packages.ipython
        ]
        ++ lib.optionals (lib.hasAttr "pipx" pkgs.python3Packages) [
          python3Packages.pipx
        ]
        ++ lib.optionals (lib.hasAttr "poetry" pkgs) [
          poetry # Poetry is now a top-level package
        ]
        ++ lib.optionals (lib.hasAttr "python-lsp-server" pkgs.python3Packages) [
          python3Packages.python-lsp-server
        ]);

    rust = with pkgs;
      lib.optionals features.rust ([
          # Core Rust toolchain
          rustc
          cargo
          rustfmt
          clippy
          rust-analyzer
        ]
        ++ lib.optionals (lib.hasAttr "cargo-watch" pkgs) [
          cargo-watch
        ]
        ++ lib.optionals (lib.hasAttr "cargo-edit" pkgs) [
          cargo-edit
        ]
        ++ lib.optionals (lib.hasAttr "cargo-audit" pkgs) [
          cargo-audit
        ]
        ++ lib.optionals (lib.hasAttr "cargo-outdated" pkgs) [
          cargo-outdated
        ]
        ++ lib.optionals (lib.hasAttr "cargo-expand" pkgs) [
          cargo-expand
        ]);

    go = with pkgs;
      lib.optionals features.go ([
          # Core Go
          go

          # Development tools
          gopls
          golangci-lint
          delve
        ]
        ++ lib.optionals (lib.hasAttr "go-tools" pkgs) [
          go-tools
        ]
        ++ lib.optionals (lib.hasAttr "gotests" pkgs) [
          gotests
        ]
        ++ lib.optionals (lib.hasAttr "gomodifytags" pkgs) [
          gomodifytags
        ]
        ++ lib.optionals (lib.hasAttr "gore" pkgs) [
          gore
        ]);

    node = with pkgs;
      lib.optionals features.node [
        # Core Node.js
        nodejs
        nodePackages.npm
        nodePackages.yarn
        nodePackages.pnpm

        # TypeScript
        nodePackages.typescript
        nodePackages.typescript-language-server

        # Development tools
        nodePackages.prettier
        nodePackages.eslint
        nodePackages.nodemon
        nodePackages.pm2
      ];

    # Additional language support
    lua = with pkgs;
      lib.optionals (features.lua or false) [
        lua
        luarocks
        lua-language-server
        stylua
      ];

    nix = with pkgs;
      lib.optionals (features.nix or true) [
        nil # Nix language server
        alejandra
        statix
        deadnix
        nix-tree
        nix-diff
      ];
  };

  # Enhanced core packages with better development experience
  corePackages = with pkgs;
    [
      # Essential shell tools
      bash
      zsh
      fish

      # Core utilities
      coreutils
      findutils
      gnused
      gnugrep
      gawk

      # Version control
      git
      git-lfs
      lazygit

      # Nix tools
      nix
      nix-direnv

      # Task runners and build tools
      just

      # System monitoring and navigation
      bottom
      htop
      zoxide
      fzf
      ripgrep
      fd

      # Text editors and viewers
      helix
      neovim
      bat
      less

      # Claude Code workflow tools
      delta # Syntax-highlighted git diffs
      tokei # Code statistics
      hyperfine # Benchmarking
      watchexec # File watcher
      tldr # Simplified man pages
      sd # Simpler sed alternative

      # Network tools
      curl
      wget
      httpie

      # File tools
      tree

      # JSON/YAML tools
      jq
      yq-go

      # Archive tools
      unzip
      zip
      gzip
    ]
    ++ lib.optionals (lib.hasAttr "gnumake" pkgs) [
      gnumake # GNU Make build tool
    ]
    ++ lib.optionals (lib.hasAttr "eza" pkgs) [
      eza # Modern ls replacement
    ]
    ++ lib.optionals (lib.hasAttr "du-dust" pkgs) [
      du-dust # Intuitive du replacement
    ]
    ++ lib.optionals (lib.hasAttr "gnutar" pkgs) [
      gnutar # GNU tar archiver
    ];

  # Combine all packages
  allPackages =
    corePackages
    ++ languagePackages.python
    ++ languagePackages.rust
    ++ languagePackages.go
    ++ languagePackages.node
    ++ languagePackages.lua
    ++ languagePackages.nix;

  # Enhanced devshell script with better functionality
  devshellScript = pkgs.writeShellApplication {
    name = "devshell";
    text = builtins.readFile ./devshell.sh;
    runtimeInputs = allPackages;
  };

  # Create a development environment package
  devEnv = pkgs.buildEnv {
    name = "development-environment";
    paths = allPackages;
    pathsToLink = ["/bin" "/share"];
  };
in {
  # Export both the script and the environment
  script = devshellScript;
  environment = devEnv;
  packages = allPackages;

  # Language-specific environments
  environments = {
    python = pkgs.buildEnv {
      name = "python-dev-env";
      paths = corePackages ++ languagePackages.python;
    };

    rust = pkgs.buildEnv {
      name = "rust-dev-env";
      paths = corePackages ++ languagePackages.rust;
    };

    go = pkgs.buildEnv {
      name = "go-dev-env";
      paths = corePackages ++ languagePackages.go;
    };

    node = pkgs.buildEnv {
      name = "node-dev-env";
      paths = corePackages ++ languagePackages.node;
    };
  };

  # Default export is the script for backward compatibility
  default = devshellScript;
}
