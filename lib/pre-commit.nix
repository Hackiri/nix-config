# Git pre-commit hooks configuration
{
  inputs,
  system,
  src,
}:
inputs.git-hooks.lib.${system}.run {
  inherit src;
  hooks = {
    alejandra.enable = true;
    deadnix.enable = true;
    statix.enable = true;
    stylua.enable = true;
    shellcheck.enable = true;
    prettier.enable = true;
  };
}
