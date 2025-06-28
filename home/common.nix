# Common Home Manager config for all systems
{
  config,
  pkgs,
  ...
}: {
  # Import module configurations
  imports = [
    ./tmux
    ./terminal
    ./starship
    ./yazi
    ./emacs
    ./direnv
    ./neovim
    ./neovide
    ./btop
  ];
  # Common packages for all systems
  home.packages = with pkgs; [
    # Version control
    git
    lazygit

    # Network utilities
    curl
    wget

    # GUI applications
    neovide

    # Shell enhancements
    direnv # Directory environment manager
    fzf # Fuzzy finder
    zoxide # Smarter cd command
    eza # Enhanced ls command
    colordiff # diff with syntax highlighting

    # Additional useful tools
    bat # Better cat with syntax highlighting
    ripgrep # Better grep
    fd # Better find
    jq # JSON processor
    uv # Package manager for Node.js
    yarn # Package manager for Node.js
    pnpm # Package manager for Node.js

    # Programming languages and tools
    # Note: Language servers are now managed by Mason in Neovim
    # Core language runtimes still provided by Nix for system-wide use
    # Python packages moved to darwin.nix
    nodejs # Node.js runtime
    php84Packages.composer # PHP package manager
    nixd # Nix language server

    # Development tools
    pre-commit # Git pre-commit hook framework
    alejandra # Nix formatter
    deadnix # Find dead Nix code
    statix # Lint Nix files
    stylua # Lua formatter
  ];

  # Common program configurations
  programs = {
    bash = {
      enable = true;
      shellAliases = {
        ll = "eza -l";
        updatenix = "sudo darwin-rebuild switch --flake ~/nix-config#nix-darwin";
        diff = "colordiff --color=always";
      };
    };

    gpg = {
      enable = true;
      settings = {
        trust-model = "tofu+pgp";
      };
    };

    git = let
      # Import secrets if the file exists, otherwise use placeholder values
      secrets =
        if builtins.pathExists ./secrets.nix
        then import ./secrets.nix
        else {
          git = {
            userName = "user";
            userEmail = "user@example.com";
            signingKey = "";
          };
        };
    in {
      enable = true;
      inherit (secrets.git) userName userEmail;
      signing = {
        signByDefault = true;
        key = secrets.git.signingKey;
      };
      extraConfig = {
        commit.gpgsign = true;
        tag.gpgsign = true;
      };
    };
  };
}
