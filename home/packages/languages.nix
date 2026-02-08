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
    python313 # Python 3.13 programming language
    python313Packages.pip # Python package manager
    python313Packages.pynvim # Python client for Neovim
    uv # Fast Python package installer and resolver

    # Python utilities (pytest/pylint provided by devshell)
    python313Packages.pygments # Syntax highlighting (pygmentize)
    python313Packages.markdown # Markdown processing
    python313Packages.tabulate # Pretty-print tabular data
    python313Packages.pylatexenc # LaTeX to text converter

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
    ruby_3_4 # Ruby programming language

    #--------------------------------------------------
    # PHP
    #--------------------------------------------------
    php84 # PHP runtime
    php84Packages.composer # Dependency manager for PHP
  ];
}
