# This file exports all custom packages
{pkgs}: let
  inherit (pkgs) lib;

  # omnictl pinned past nixpkgs to match self-hosted Omni's API version
  omnictl = import ./omnictl.nix {inherit pkgs lib;};

  # Kubernetes tool collections
  kubernetes-tools = import ./kubernetes-tools.nix {inherit pkgs omnictl;};
in {
  inherit kubernetes-tools omnictl;

  # Convenience function to create a package set with all kubernetes tools
  kube-packages = pkgs.buildEnv {
    name = "kubernetes-packages";
    paths = kubernetes-tools.all;
  };
}
