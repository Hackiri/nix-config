# Custom packages from overlays and local builds
# These are packages built from your custom pkgs/ directory
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Development tools helper script
    dev-tools

    # Development shell environment
    devshell

    # Kubernetes tools (if needed)
    # kube-packages
    
    # Add more custom packages here as they're created
    # my-custom-tool
    # project-specific-scripts
  ];
}
