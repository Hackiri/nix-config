# Custom packages from overlays
{pkgs, ...}: {
  # Import custom packages from overlays
  home.packages = with pkgs; [
    # Kubernetes tools (these are a list)
    kube-tools
    
    # Development tools (these are attribute sets)
    dev-tools
    
    # Development shell
    devshell
  ];
}
