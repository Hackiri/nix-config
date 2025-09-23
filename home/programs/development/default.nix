# Development tools and configurations
{...}: {
  imports = [
    ./git/git-hooks.nix
    ./direnv
    ./kube/kube.nix
    ./kube/kube-config.nix
  ];
}
