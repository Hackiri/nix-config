{
  pkgs,
  config,
  ...
}: {
  programs.bash = {
    enable = true;
    shellAliases = import ../zsh/aliases.nix;
  };
}
