# Build tools and compilers
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Build automation and compilation
    gnumake # Build automation tool
    gcc # GNU Compiler Collection
    lldb_17 # Next generation debugger
    cmake # Cross-platform build system generator
    libtool # Generic library support script
    pkg-config # Helper tool for compiling applications
  ];
}
