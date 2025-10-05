# Custom packages from overlays and local builds
# These are packages built from your custom pkgs/ directory
{pkgs, ...}: let
  # Import your custom packages
  customPkgs = import ../../../pkgs {inherit pkgs;};
in {
  home.packages = with pkgs; [
    # Development tools helper script
    customPkgs.dev-tools

    # Development shell script (not the full environment)
    customPkgs.devshell.script

    # Note: Kubernetes tools are now managed via programs.kube module
    # Enable in your host config with: programs.kube.enable = true;
    # Customize toolset with: programs.kube.toolset = "admin"; (or minimal/devops/complete)

    # Add more custom packages here as they're created
    # my-custom-tool
    # project-specific-scripts
  ];
}
