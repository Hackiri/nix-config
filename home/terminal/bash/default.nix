{
  pkgs,
  config,
  ...
}: {
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "eza -l";
      updatenix = "sudo darwin-rebuild switch --flake ~/nix-config#nix-darwin";
      diff = "colordiff --color=always";
    };
  };
}