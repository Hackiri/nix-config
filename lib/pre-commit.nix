# Git pre-commit hooks configuration
{
  inputs,
  system,
  src,
}:
inputs.git-hooks.lib.${system}.run {
  inherit src;
  hooks = {
    treefmt.enable = true;
  };
}
