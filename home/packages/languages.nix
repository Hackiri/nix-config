# Programming languages and runtimes
{pkgs, ...}: {
  home.packages = with pkgs; [
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

    # Node, Go, Rust, Ruby, PHP available via devShells:
    # nix develop .#node / .#go / .#rust / .#ruby / .#php
  ];
}
