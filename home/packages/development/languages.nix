# Programming languages and runtimes
{pkgs, ...}: {
  home.packages = with pkgs; [
    #--------------------------------------------------
    # Python Ecosystem
    #--------------------------------------------------
    python314 # Python 3.14 programming language
    python314Packages.pip # Python package manager
    python314Packages.pynvim # Python client for Neovim
    uv # Fast Python package installer and resolver

    # Python utilities (pytest/pylint provided by devshell)
    python314Packages.pygments # Syntax highlighting (pygmentize)
    python314Packages.markdown # Markdown processing
    python314Packages.tabulate # Pretty-print tabular data
    python314Packages.pylatexenc # LaTeX to text converter

    # Node, Go, Rust, Ruby, PHP available via devShells:
    # nix develop .#node / .#go / .#rust / .#ruby / .#php
  ];
}
