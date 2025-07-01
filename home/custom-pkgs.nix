# Custom packages from overlays
{pkgs, ...}: {
  # Import custom packages from overlays
  home.packages = with pkgs; 
    # Combine all the package lists
    kube-tools ++
    dev-tools ++
    (if builtins.isList devshell then devshell else [devshell]);
}
