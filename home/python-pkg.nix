# Python packages with no configuration
{pkgs, ...}: {
  # Python packages for all systems that don't require specific configuration
  home.packages = with pkgs; [
    #--------------------------------------------------
    # Python Core
    #--------------------------------------------------
    python312 # Python programming language
    python312Packages.pip # Python package manager (needed for Mason)

    #--------------------------------------------------
    # Python Development Tools
    #--------------------------------------------------
    uv # Modern Python package manager

    #--------------------------------------------------
    # Python Libraries and Utilities
    #--------------------------------------------------
    python3Packages.pygments # Syntax highlighting (pygmentize)
    python3Packages.pynvim # Python client for Neovim

    #--------------------------------------------------
    # Python Testing and Quality Tools
    #--------------------------------------------------
    python3Packages.pytest_7 # Testing framework
    python3Packages.pylint # Linter

    #--------------------------------------------------
    # Python Documentation and Formatting
    #--------------------------------------------------
    python3Packages.markdown # Markdown processing
    python3Packages.tabulate # Pretty-print tabular data

    #--------------------------------------------------
    # Python LaTeX Tools
    #--------------------------------------------------
    python3Packages.pylatexenc # LaTeX to text converter
  ];
}
