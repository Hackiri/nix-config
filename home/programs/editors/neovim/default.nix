{pkgs, ...}: {
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
        pip # Required by mason.nvim
        pynvim
        pylatexenc # Provides latex2text for render-markdown.nvim
      ];

    # Add Lua packages for Neovim plugins
    extraLuaPackages = ps:
      with ps; [
        jsregexp # For LuaSnip transformations
        magick # For image.nvim and other image manipulation plugins
      ];

    extraPackages = with pkgs; [
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
    ];

    extraLuaConfig = ''
      -- Set leader key before lazy
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      -- Python configuration
      -- Nix provides Python with required packages via extraPython3Packages
      -- Neovim will automatically find it in PATH (no need to set python3_host_prog)

      -- Capture neovim_mode from environment variable
      vim.g.neovim_mode = vim.env.NEOVIM_MODE or "default"
      vim.g.md_heading_bg = vim.env.MD_HEADING_BG

      -- Load lazy.nvim configuration
      require("config.lazy")

      -- Load your Lua configuration
      require("config")
    '';
  };

  # Symlink custom Lua configuration files, dictionaries, and spell files
  xdg.configFile = {
    "nvim/lua" = {
      source = ./lua;
      recursive = true;
    };

    # Symlink dictionaries for blink-cmp dictionary completion
    "nvim/dictionaries" = {
      source = ./dictionaries;
      recursive = true;
    };

    # Symlink spell files for vim spell checking and dictionary completion
    "nvim/spell" = {
      source = ./spell;
      recursive = true;
    };
  };
}
