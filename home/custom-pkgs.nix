# Custom packages from overlays
{pkgs, ...}: {
  # Import custom packages from overlays
  home.packages = with pkgs; [
    # Development tools - access the specific derivation
    # dev-tools is an attribute set with a derivation inside
    dev-tools.dev-tools

    # Development shell - access the specific derivation if needed
    # If devshell is a direct derivation, this would work
    devshell
  ];
}
