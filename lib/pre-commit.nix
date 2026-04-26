# Git pre-commit hooks configuration
{
  inputs,
  system,
  src,
  treefmt,
}:
inputs.git-hooks.lib.${system}.run {
  inherit src;
  hooks = {
    treefmt = {
      enable = true;
      package = treefmt;
    };
  };
}
