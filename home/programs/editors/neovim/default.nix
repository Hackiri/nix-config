{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [];
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = false;

    # Add pynvim for Python support
    extraPython3Packages = ps: with ps; [pynvim];

    extraPackages = with pkgs; [
      tree-sitter
      fzf
      vscode-js-debug
      # For LuaSnip transformations
      lua51Packages.lua
      lua51Packages.luarocks

      # Build tools for native extensions
      cmake
      gcc
      gnumake

      # Image and document rendering tools
      imagemagick # Provides magick/convert for image conversion
      ghostscript # Provides gs for PDF rendering
      tectonic # LaTeX rendering
      mermaid-cli # Provides mmdc for Mermaid diagrams
      pngpaste # For img-clip.nvim clipboard image pasting
    ];

    extraLuaConfig = ''
      -- Set leader key before lazy
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      -- Use system Python
      -- vim.g.python3_host_prog is not set, so Neovim will find Python in PATH

      -- Capture neovim_mode from environment variable
      vim.g.neovim_mode = vim.env.NEOVIM_MODE or "default"
      vim.g.md_heading_bg = vim.env.MD_HEADING_BG

      -- Load lazy.nvim configuration
      require("config.lazy")

      -- Load your Lua configuration
      require("config")
    '';
  };

  # Symlink custom Lua configuration files
  xdg.configFile."nvim/lua" = {
    source = ./lua;
    recursive = true;
  };
}
