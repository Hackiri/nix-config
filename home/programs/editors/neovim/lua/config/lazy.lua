-- lua/config/lazy.lua

-- Set leader key before lazy
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

-- Set the python3_host_prog variable
vim.g.python3_host_prog = vim.fn.expand("~/.venvs/neovim/bin/python")

-- Compatibility aliases for legacy modules before plugin load
-- Some plugins still `require("nvim-treesitter.query")` on Neovim 0.11+.
-- Route that to our compat shim in lua/compat/treesitter_query.lua.
package.preload["nvim-treesitter.query"] = function()
  -- Inline compat shim so we don't depend on package.path
  local q
  local ok = pcall(function()
    q = vim.treesitter and vim.treesitter.query or nil
  end)
  if not ok or type(q) ~= "table" then
    local ok_tsq, tsq = pcall(require, "nvim-treesitter.ts_query")
    if ok_tsq then
      q = tsq
    else
      q = {}
    end
  end

  local M = {}
  function M.get_query(lang, name)
    if q.get_query then return q.get_query(lang, name) end
    if q.get then return q.get(lang, name) end
    return nil
  end
  function M.get(lang, name)
    if q.get then return q.get(lang, name) end
    if q.get_query then return q.get_query(lang, name) end
    return nil
  end
  function M.get_files(lang, name, is_included)
    if q.get_files then return q.get_files(lang, name, is_included) end
    return {}
  end
  function M.parse(lang, query_string)
    if q.parse then return q.parse(lang, query_string) end
    return nil
  end
  function M.get_node_text(node, bufnr)
    if vim.treesitter and vim.treesitter.get_node_text then
      return vim.treesitter.get_node_text(node, bufnr)
    end
    local ok_ts_utils, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
    if ok_ts_utils and ts_utils.get_node_text then
      return ts_utils.get_node_text(node, bufnr)
    end
    return ""
  end
  return M
end

-- Make sure the parser install dir is on the runtimepath for nvim-treesitter
do
  local site = vim.fn.stdpath("data") .. "/site"
  local rtp = vim.o.runtimepath or ""
  -- Compare as comma-delimited list to avoid partial matches
  if not string.find("," .. rtp .. ",", "," .. site .. ",", 1, true) then
    vim.opt.runtimepath:append(site)
  end
end

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
    lazy = false,
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
      version = "1.*", -- Use stable version tag instead of requiring Rust nightly
      build = "mkdir -p build && cc -O3 -Wall -fpic -std=gnu99 -shared src/fzf.c -o build/libfzf.so",
    },
    -- Import user plugins
    -- import any extras modules here
    { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
    { import = "lazyvim.plugins.extras.ui.mini-animate" },
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
