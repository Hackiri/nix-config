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

    -- LazyVim Extras - Workflow Enhancements
    { import = "lazyvim.plugins.extras.util.mini-hipatterns" }, -- Highlight hex colors, etc.
    { import = "lazyvim.plugins.extras.coding.yanky" }, -- Advanced yank history with picker
    { import = "lazyvim.plugins.extras.editor.mini-diff" }, -- Inline git diff visualization
    { import = "lazyvim.plugins.extras.editor.mini-move" }, -- Move lines/blocks with Alt+hjkl
    -- { import = "lazyvim.plugins.extras.editor.illuminate" }, -- Highlight word references (disabled - Neovim 0.11 compatibility issue)
    { import = "lazyvim.plugins.extras.util.project" }, -- Project-based directory switching
    { import = "lazyvim.plugins.extras.editor.refactoring" }, -- Code refactoring operations

    -- LazyVim Extras - AI
    { import = "lazyvim.plugins.extras.ai.copilot" }, -- Copilot + blink-cmp source
    { import = "lazyvim.plugins.extras.ai.copilot-chat" }, -- CopilotChat with defaults
    { import = "lazyvim.plugins.extras.ai.avante" }, -- Cursor-like AI sidebar
    { import = "lazyvim.plugins.extras.ai.sidekick" }, -- Next Edit Suggestions (by Folke)

    -- Your custom plugins
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
      plugin = " ",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
})
