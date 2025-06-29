# Common Home Manager config for all systems
{
  config,
  pkgs,
  ...
}: {
  # Import module configurations
  imports = [
    ./tmux
    ./terminal
    ./starship
    ./yazi
    ./emacs
    ./direnv
    ./neovim
    ./neovide
    ./btop
    ./common-pkg.nix
    ./python-pkg.nix
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
