{ pkgs ? import <nixpkgs> {} }:

let
  # Import configuration
  config = import ./config.nix;
  
  # Extract enabled features
  features = config.programs.devshell.features;
  
  # Define language-specific packages based on enabled features
  pythonPackages = if features.python then with pkgs; [
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.black
    python3Packages.flake8
    python3Packages.isort
  ] else [];
  
  rustPackages = if features.rust then with pkgs; [
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
  ] else [];
  
  goPackages = if features.go then with pkgs; [
    go
    gopls
    golangci-lint
    delve
  ] else [];
  
  nodePackages = if features.node then with pkgs; [
    nodejs
    nodePackages.npm
    nodePackages.yarn
    nodePackages.typescript
    nodePackages.typescript-language-server
  ] else [];
  
  # Core packages that are always included
  corePackages = with pkgs; [
    bash
    coreutils
    git
    nix
    just
    lazygit
    bottom
    zoxide
    helix
    bat
    less
  ];
  
  # Combine all packages
  allPackages = corePackages ++ pythonPackages ++ rustPackages ++ goPackages ++ nodePackages;

in pkgs.stdenv.mkDerivation {
  name = "devshell";
  version = "1.0.0";
  
  src = ./.;
  
  buildInputs = allPackages;
  
  installPhase = ''
    mkdir -p $out/bin
    cp devshell.sh $out/bin/devshell
    chmod +x $out/bin/devshell
  '';
  
  meta = {
    description = "Development shell environment launcher";
    mainProgram = "devshell";
  };
}
