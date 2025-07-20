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
    ./tmux
    ./terminal
    ./common-pkg.nix
    ./python-pkg.nix
    ./kube.nix
    ./git-hooks.nix
    ./kube-config.nix
    ./custom-pkgs.nix
    # ./sops.nix
  ];
}
