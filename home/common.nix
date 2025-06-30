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
    ./emacs
    ./direnv
    ./neovim
    ./neovide
    ./tmux
    ./terminal
    ./common-pkg.nix
    ./python-pkg.nix
    ./kube.nix
    ./git-hooks.nix
    ./kube-config.nix
  ];

  # Common program configurations
  programs = {
    bash = {
      enable = true;
      shellAliases = {
        ll = "eza -l";
        updatenix = "sudo darwin-rebuild switch --flake ~/nix-config#nix-darwin";
        diff = "colordiff --color=always";
      };
    };
  };
}
