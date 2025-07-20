# Common Home Manager config for all systems
{
  config,
  pkgs,
  ...
}: {
  # Import module configurations
  imports = [
    ./btop
    ./starship
    ./yazi
    ./direnv
    ./emacs
    ./neovim
    ./neovide
    ./python/python-pkg.nix
    ./sops-nix/sops.nix
    ./git/git-hooks.nix
    ./kube/kube.nix
    ./kube/kube-config.nix
    ./tmux
    ./terminal
    ./common-pkg.nix
    ./custom-pkgs.nix
  ];
}
