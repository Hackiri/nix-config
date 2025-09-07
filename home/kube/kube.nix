{
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable Kubernetes tools configuration
  programs.kube.enable = true;

  # Additional Kubernetes-specific configurations can go here
  # For example, kubeconfig management, custom scripts, etc.
}
