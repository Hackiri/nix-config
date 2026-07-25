-- lua/config/lazy.lua
-- Leader keys are set in default.nix initLua before this file loads

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local clone_ok, clone = pcall(vim.system, {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }, { text = true })
  if not clone_ok then
    error("Failed to start lazy.nvim clone:\n" .. tostring(clone))
  end

  clone = clone:wait()
  if clone.code ~= 0 then
    local output = clone.stderr and clone.stderr ~= "" and clone.stderr or clone.stdout
    error("Failed to clone lazy.nvim:\n" .. (output and output ~= "" and output or "unknown error"))
  end
end
vim.opt.rtp:prepend(lazypath)

-- Python is provided by Nix via extraPython3Packages in default.nix
-- Neovim will automatically find it in PATH

-- Set up lazy.nvim
require("lazy").setup({
  defaults = {
    lazy = true, -- Enable lazy loading by default for better startup time
    version = false,
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
    -- Disabled because LazyVim's refactoring extra adds lewis6991/async.nvim,
    -- whose top-level `async` module conflicts with nvim-ufo's promise-async.
    -- The collision makes ufo fail when it attaches to file and floating buffers.
    -- { import = "lazyvim.plugins.extras.editor.refactoring" },

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
