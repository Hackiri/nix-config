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
    ./devshell
    ./devshell-config.nix
    ./direnv
    ./neovim
    ./neovide
    ./btop
    ./common-pkg.nix
    ./python-pkg.nix
  ];
  # Common packages are now imported from common-pkg.nix

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

    gpg = {
      enable = true;
      settings = {
        trust-model = "tofu+pgp";
      };
    };

    git = let
      # Import secrets if the file exists, otherwise use placeholder values
      secrets =
        if builtins.pathExists ./secrets.nix
        then import ./secrets.nix
        else {
          git = {
            userName = "user";
            userEmail = "user@example.com";
            signingKey = "";
          };
        };
    in {
      enable = true;
      inherit (secrets.git) userName userEmail;
      signing = {
        signByDefault = true;
        key = secrets.git.signingKey;
      };
      extraConfig = {
        commit.gpgsign = true;
        tag.gpgsign = true;
      };
    };
  };
}
