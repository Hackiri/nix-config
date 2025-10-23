# Development tools and configurations
# Note: Basic Git config is included here.
# For Git with sops-integrated hooks, import the secrets profile instead.
{...}: {
  imports = [
    ./git/default.nix # Basic Git without sops
    ./direnv
  ];
}
