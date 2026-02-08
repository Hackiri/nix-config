{pkgs, ...}: {
  programs.bash = {
    enable = true;
    shellAliases = import ../zsh/aliases.nix {inherit (pkgs.stdenv) isDarwin;};
  };
}
