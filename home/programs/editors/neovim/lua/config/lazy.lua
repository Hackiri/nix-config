-- lua/config/lazy.lua
-- Leader keys are set in default.nix extraLuaConfig before this file loads

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Python is provided by Nix via extraPython3Packages in default.nix
-- Neovim will automatically find it in PATH

-- Setup treesitter compatibility shims for Neovim 0.11+
require("compat.treesitter").setup()

-- Safe require function to handle missing modules
local function safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify("Could not load " .. module, vim.log.levels.WARN)
    return nil
  end
  return result
end

-- Set up lazy.nvim
require("lazy").setup({
  defaults = {
    lazy = true, -- Enable lazy loading by default for better startup time
    version = false,
  },
  dev = {
    path = vim.fn.stdpath("data") .. "/lazy",
    patterns = { "." },
    fallback = true,
  },
  spec = {
    -- Import LazyVim plugins
    { "LazyVim/LazyVim", version = "*", import = "lazyvim.plugins" },
    -- Explicitly enable specific plugins

    -- Other plugin configurations
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      enabled = true,
      version = "false", -- Use stable version tag instead of requiring Rust nightly
      build = "mkdir -p build && cc -O3 -Wall -fpic -std=gnu99 -shared src/fzf.c -o build/libfzf.so",
    },
    -- Import user plugins
    -- import any extras modules here
    { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
    -- Disabled to prevent duplicate <leader>ua keymaps
    -- { import = "lazyvim.plugins.extras.ui.mini-animate" },
    { import = "lazyvim.plugins.extras.formatting.prettier" },
    -- { import = "lazyvim.plugins.extras.ai.codeium" }, -- Replaced with windsurf.vim plugin
    -- Copilot is configured in plugins/copilot.lua
    { import = "plugins" },
    -- Import colorschemes from the colorschemes directory
    { import = "plugins.colorschemes" },
  },
  install = { colorscheme = {} },
  checker = { enabled = true },
  performance = {
    enabled = true,
    rtp = {
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        -- "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    -- If you have a Nerd Font, set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
})
