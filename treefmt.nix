{
  # Project root
  projectRootFile = "flake.nix";

  programs = {
    # Nix
    alejandra.enable = true;
    deadnix.enable = true;
    statix.enable = true;

    # Lua (for Neovim config)
    stylua.enable = true;

    # Shell
    shellcheck.enable = true;
    shfmt.enable = true;

    # Other
    prettier.enable = true;
  };
}
