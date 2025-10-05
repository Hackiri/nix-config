# Programming languages and runtimes
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # Node.js Ecosystem
    #--------------------------------------------------
    nodejs # JavaScript runtime environment
    yarn # Fast, reliable, and secure dependency management
    pnpm # Fast, disk space efficient package manager
    bun # Fast all-in-one JavaScript runtime

    #--------------------------------------------------
    # Python Ecosystem
    #--------------------------------------------------
    python312 # Python 3.12 programming language
    python312Packages.pip # Python package manager
    uv # Fast Python package installer and resolver

    # Python development tools
    python312Packages.pytest # Testing framework
    python312Packages.pylint # Linter
    python312Packages.pynvim # Python client for Neovim

    # Python utilities
    python3Packages.pygments # Syntax highlighting (pygmentize)
    python3Packages.markdown # Markdown processing
    python3Packages.tabulate # Pretty-print tabular data
    python3Packages.pylatexenc # LaTeX to text converter

    #--------------------------------------------------
    # Go
    #--------------------------------------------------
    go # Go programming language

    #--------------------------------------------------
    # Rust
    #--------------------------------------------------
    rustc # Rust compiler
    cargo # Rust package manager
    rustfmt # Rust code formatter
    clippy # Rust linter

    #--------------------------------------------------
    # Ruby
    #--------------------------------------------------
    ruby_3_3 # Ruby programming language

    #--------------------------------------------------
    # PHP
    #--------------------------------------------------
    php84 # PHP runtime
    php84Packages.composer # Dependency manager for PHP
  ];
}
