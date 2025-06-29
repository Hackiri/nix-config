{pkgs ? import <nixpkgs> {}}: let
  # Import configuration
  config = import ./config.nix;

  # Extract enabled features
  inherit (config.programs.devshell) features;

  # Define language-specific packages
  pythonPackages = with pkgs;
    if features.python
    then [
      python3
      python3Packages.pip
      python3Packages.virtualenv
      python3Packages.black
      python3Packages.flake8
      python3Packages.isort
    ]
    else [];

  rustPackages = with pkgs;
    if features.rust
    then [
      rustc
      cargo
      rustfmt
      clippy
      rust-analyzer
    ]
    else [];

  goPackages = with pkgs;
    if features.go
    then [
      go
      gopls
      golangci-lint
      delve
    ]
    else [];

  nodePackages = with pkgs;
    if features.node
    then [
      nodejs
      nodePackages.npm
      nodePackages.yarn
      nodePackages.typescript
      nodePackages.typescript-language-server
    ]
    else [];

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

  # Create the devshell script
  devshellScript = pkgs.writeShellScriptBin "devshell" (builtins.readFile ./devshell.sh);
in
  devshellScript
