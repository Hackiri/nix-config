# Custom packages from overlays and local builds
# These are packages built from your custom pkgs/ directory
{pkgs, ...}: let
  # Import your custom packages
  customPkgs = import ../../pkgs {inherit pkgs;};
in {
  home.packages = with pkgs; [
    # Development tools helper script
    customPkgs.dev-tools

    # Development shell script (not the full environment)
    customPkgs.devshell.script

    # Kubernetes tools
    customPkgs.kube-packages

    # Add more custom packages here as they're created
    # my-custom-tool
    # project-specific-scripts
  ];
}
