# This file exports all custom packages
{ pkgs ? import <nixpkgs> {} }:

rec {
  # Development tools package
  dev-tools = import ./dev-tools.nix { inherit pkgs; };
  
  # Add more packages here as needed
  # For example:
  # my-package = pkgs.callPackage ./my-package { };
  # python-with-packages = pkgs.python3.withPackages (ps: with ps; [ 
  #   numpy
  #   pandas
  #   # Add more Python packages here
  # ]);
  
  # You can also create package sets
  # development-tools = {
  #   inherit dev-tools;
  #   inherit my-package;
  #   # Add more related packages here
  # };
}
