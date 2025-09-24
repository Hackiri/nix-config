# This file exports all custom packages
{pkgs ? import <nixpkgs> {}}: rec {
  # Development tools package - now returns the package directly
  dev-tools = import ./dev-tools.nix {inherit pkgs;};

  # Development shell environment
  devshell = import ./devshell {inherit pkgs;};

  # Kubernetes and infrastructure tools
  kubernetes-tools = import ./kubernetes-tools.nix {inherit pkgs;};

  # Convenience function to create a package set with all kubernetes tools
  kube-packages = pkgs.buildEnv {
    name = "kubernetes-packages";
    paths = kubernetes-tools;
  };

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
