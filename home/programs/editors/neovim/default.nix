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

    # Add pynvim for Python support and pylatexenc for render-markdown LaTeX support
    extraPython3Packages = ps:
      with ps; [
        pynvim
        pylatexenc # Provides latex2text for render-markdown.nvim
      ];

    # Add jsregexp for LuaSnip transformations
    extraLuaPackages = ps: with ps; [jsregexp];

    extraPackages = with pkgs;
      [
        tree-sitter
        fzf
        vscode-js-debug
        # For LuaSnip transformations (Lua 5.1 required)
        lua51Packages.lua
        lua51Packages.luarocks
        luajit

        # Build tools for native extensions
        cmake
        gcc
        gnumake

        # Image and document rendering tools
        imagemagick # Provides magick/convert for image conversion
        ghostscript # Provides gs for PDF rendering
        tectonic # LaTeX rendering
        mermaid-cli # Provides mmdc for Mermaid diagrams

        # Formatters and linters for conform.nvim and diagnostics
        nodePackages.prettier # JavaScript/TypeScript/CSS/HTML/JSON/YAML/Markdown formatter
        stylua # Lua formatter
        shfmt # Shell script formatter
        shellcheck # Shell script linter
        python311Packages.ruff # Python linter and formatter (CLI)
        templ # Go template formatter
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        # GNU coreutils for yazi.nvim (provides grealpath) - NixOS only
        coreutils
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [
        pngpaste # For img-clip.nvim clipboard image pasting (macOS only)
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

  # Symlink dictionaries for blink-cmp dictionary completion
  xdg.configFile."nvim/dictionaries" = {
    source = ./dictionaries;
    recursive = true;
  };

  # Symlink spell files for vim spell checking and dictionary completion
  xdg.configFile."nvim/spell" = {
    source = ./spell;
    recursive = true;
  };
}
