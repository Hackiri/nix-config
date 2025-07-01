# Custom packages from overlays
{pkgs, ...}: {
  # Import custom packages from overlays
  home.packages = with pkgs; [
    # Individual kubernetes tools - these are a list of packages
    # so we need to include them individually
    kubectl
    kubernetes-helm
    k9s
    cilium-cli
    kustomize
    krew
    talosctl
    terraform
    kubernetes-helmPlugins.helm-diff
    
    # Development tools - access the specific derivation
    # dev-tools is an attribute set with a derivation inside
    dev-tools.dev-tools
    
    # Development shell - access the specific derivation if needed
    # If devshell is a direct derivation, this would work
    devshell
  ];
}
