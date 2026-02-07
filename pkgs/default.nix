# This file exports all custom packages
{pkgs}: rec {
  # Development tools script
  dev-tools = import ./scripts/dev-tools.nix {inherit pkgs;};

  # Development shell environment (returns an attribute set with script, environment, etc.)
  devshell = import ./scripts/devshell {inherit pkgs;};

  # Kubernetes tool collections
  kubernetes-tools = import ./collections/kubernetes-tools.nix {inherit pkgs;};

  # Convenience function to create a package set with all kubernetes tools
  kube-packages = pkgs.buildEnv {
    name = "kubernetes-packages";
    paths = kubernetes-tools.all; # Use .all to get the list of all packages
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
