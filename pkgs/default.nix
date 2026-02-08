# This file exports all custom packages
{pkgs}: let
  # Kubernetes tool collections
  kubernetes-tools = import ./collections/kubernetes-tools.nix {inherit pkgs;};
in {
  inherit kubernetes-tools;

  # Convenience function to create a package set with all kubernetes tools
  kube-packages = pkgs.buildEnv {
    name = "kubernetes-packages";
    paths = kubernetes-tools.all;
  };
}
